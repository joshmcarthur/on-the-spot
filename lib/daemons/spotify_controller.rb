#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

# Load the Rails environment
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "config", "environment"))


$running = true


Signal.trap("TERM") do 
  QueuedTrack.stop!
  $running = false
end

Signal.trap("SIGINT") do
  QueuedTrack.stop!
  $running = false
end

while($running and $player) do

  while uri = $redis.lpop("play_queue")
    # Only continue if the URI looks like a spotify one
    # Thus far, we understand"
    # * spotify:track:121212121

    spotify_type = uri =~ /\Aspotify\:([a-z]*)/

    case $1
    when "track"
      QueuedTrack.play!(uri)
    else
      raise "Could not find Spotify type: #{$1}"
    end
  end
  
  sleep 5
end

