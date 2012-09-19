# QueuedTrack: Just a wrapper class around MetaSpotify and Hallon to provide
# my own business rules 
class QueuedTrack

  cattr_accessor :queue_name do
    "play_queue"
  end

  def self.find(uri)
    return unless uri.is_a?(String)
    Hallon::Track.new(uri).load
  end

  def self.present?(uri)
    # FIXME Loop through queue
    return false unless $redis.mget self.queue_name
    $redis.lrange(self.queue_name, 0, -1).each do |value|
      return true if value == uri
    end

    return false
  end

  def self.upcoming(count = 3)
    upcoming = []

    # We want to look at the beginning of the queue and pop things off there
    (0...count).to_a.each do |index|
      upcoming << self.find($redis.lindex(self.queue_name, index))
    end 

    upcoming.compact
  end

  def self.next
    $redis.lpop self.queue_name
  end


  def self.create(uri)
    return false if self.present?(uri)
    return $redis.rpush self.queue_name, uri
  end

  def self.stop!
    $player.stop
    $redis.del "currently_playing"
  end

  def self.play!(track)
    # Set the currently-playing track
    $redis.set "currently_playing", track

    # Load the track
    track = Hallon::Track.new(track).load

    # log the playing track
    Rails.logger.info "Start Playing: #{track.name}"

    begin
      # Broadcast the playing track
      PrivatePub.publish_to "/tracks/new", :track => {:name => track.name, :image_data => track.cover_image}

      $player.load(track)
      # Play the track
      $player.play!(track)
    ensure
      $redis.del "currently_playing"
    end

    # log the stopped track
    Rails.logger.info "Stop Playing: #{track.name}"

    # Broadcast that we are no longer playing the track
    PrivatePub.publish_to "/tracks/new", :stopped => true

    # Add the song that played onto the historic track queue
    PreviousTrack.create(track.uri)

    # Clear the currently playing track
    $redis.del "currently_playing"
  end

end