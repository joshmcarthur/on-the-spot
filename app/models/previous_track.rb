class PreviousTrack
  cattr_accessor :queue_name do
    "previous_tracks"
  end

  cattr_accessor :minimum_queue_length do
    5
  end


  def self.present?(uri)
    # FIXME Loop through queue
    return false unless $redis.mget self.queue_name
    $redis.lrange(self.queue_name, 0, -1).each do |value|
      return true if value == uri
    end

    return false
  end

  def self.enough?
    return $redis.llen(self.queue_name) >= self.minimum_queue_length
  end

  def self.create(uri)
    return false if self.present?(uri)
    return $redis.rpush self.queue_name, uri
  end

  def self.next
    $redis.lpop self.queue_name
  end

end