# QueuedTrack: Just a wrapper class around MetaSpotify and Hallon to provide
# my own business rules 
class QueuedTrack

  @@queue_name = "play_queue"

  def self.find(uri)
    return unless uri.is_a?(String)
    Rails.cache.fetch uri do
      Hallon::Track.new(uri).load
    end
  end

  def self.present?(uri)
    # FIXME Loop through queue
    must_have_queue!
    queue = $redis.lrange(@@queue_name, 0, -1)
    queue.each do |value|
      return true if value == uri
    end if queue

    return false
  end

  def self.next(count = 3)
    upcoming = []

    # We want to look at the beginning of the queue and pop things off there
    (0..count).to_a.each do |index|
      upcoming << self.find($redis.lindex(@@queue_name, index))
    end 

    upcoming.compact
  end 


  def self.create(uri)
    return false if self.present?(uri)
    return $redis.rpush @@queue_name, uri
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

  private

  def self.must_have_queue!
    unless $redis.get @@queue_name
      $redis.lpush @@queue_name, nil
    end
  end
end