#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

class SpotifyPlayer
  def self.play_track(track)
  # Set the currently-playing track
  $redis.set "currently_playing", track

  # Load the track
  track = Hallon::Track.new(track).load

  # log the playing track
  Rails.logger.info "Start Playing: #{track.name}"

  begin
    # Broadcast the playing track
    PrivatePub.publish_to "/tracks/new", :track => track.name 

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

  # Clear the currently playing track
  $redis.del "currently_playing"
  end
end

$running = true
$player = Hallon::Player.new(Hallon::OpenAL)
$player.volume_normalization = true

Signal.trap("TERM") do 
  $running = false
  $player.stop
  $redis.del "currently_playing"
end

while($running and $player) do

  while uri = $redis.rpop("play_queue")
    # Only continue if the URI looks like a spotify one
    # Thus far, we understand"
    # * spotify:track:121212121
    # * spotify:album:121212121

    spotify_type = uri =~ /\Aspotify\:([a-z]*)/

    case $1
    when "track"
      SpotifyPlayer.play_track(uri)
    when "album"
      tracks = Hallon::AlbumBrowse.new(Hallon::Album.new(uri)).load.tracks
      tracks.each do |track|
        SpotifyPlayer.play_track(track.to_link.to_str)
      end
    else
      raise "Could not find Spotify type: #{$1}"
    end
  end
  
  sleep 5
end

