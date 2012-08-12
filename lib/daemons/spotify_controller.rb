#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

$running = true
$player = Hallon::Player.new(Hallon::OpenAL)
$player.volume_normalization = true

Signal.trap("TERM") do 
  $running = false
  $player.stop
  $redis.del "currently_playing"
end

while($running and $player) do

  while uri = $redis.rpop("tracks")
    # Only continue if the URI looks like a spotify one
    if uri =~ /\Aspotify\:/


      # Set the currently-playing track
      $redis.set "currently_playing", uri

      # Load the track
      track = Hallon::Track.new(uri).load

      # log the playing track
      Rails.logger.info "Start Playing: #{track.name}"

      begin
        $player.load(track)
        # Play the track
        $player.play!(track)
      ensure
        $redis.del "currently_playing"
      end

      # log the stopped track
      Rails.logger.info "Stop Playing: #{track.name}"

      # Clear the currently playing track
      $redis.del "currently_playing"
    end
  end
  
  sleep 5
end
