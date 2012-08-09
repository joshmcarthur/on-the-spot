#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # Replace this with your code
  Rails.logger.auto_flushing = true
  Rails.logger.info "This daemon is still running at #{Time.now}.\n"

  $player = Hallon::Player.new(Hallon::OpenAL)

  while uri = $redis.rpop("tracks")
    # Only continue if the URI looks like a spotify one
    if uri =~ /\Aspotify\:/
      # Load the track
      track = Hallon::Track.new(uri).load

      # Set the currently-playing track
      $redis.set "currently_playing", uri

      # log the playing track
      Rails.logger.info "Start Playing: #{track.name}"

      begin
        # Play the track
        $player.play!(track)
      ensure
        $player.stop
      end

      # log the stopped track
      Rails.logger.info "Stop Playing: #{track.name}"

      # Clear the currently playing track
      $redis.del "currently_playing"
    end
  end
  
  sleep 5
end