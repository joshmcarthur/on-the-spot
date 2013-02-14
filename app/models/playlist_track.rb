class PlaylistTrack

# PlaylistTrack provides an alternative to adding songs, in 
# that it will play tracks off a given playlist until new
# songs are added to the queue, when it will play those
# and add THOSE to the playlist track.
# The playlist, then, operates as a half-radio, half-liked-tracks.

  cattr_accessor :playlist_uri do
    ENV['SPOTIFY_PLAYLIST']
  end

  def self.present?(uri)
    return self.playlist.tracks.map(&:uri).include?(uri)
  end

  def self.playlist
    @@playlist ||= Hallon::Playlist.new(self.playlist_uri)
    raise "Playlist not found" unless @@playlist
    @@playlist.load
    @@playlist
  end

  def self.enough?
    return !self.playlist.size.zero?
  end

  def self.create(uri)
    return false if self.present?(uri)
    self.playlist.insert(self.playlist.size, Hallon::Track.new(uri))
  end

  def self.next
    self.playlist.tracks.sample.to_str
  end
end