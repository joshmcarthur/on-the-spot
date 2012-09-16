class PreviousTrack

# PreviousTrack works very much like a QueuedTrack, except
# it uses a set rather than a list in Redis. The reason for this
# is that a SET provides more capability and is more efficient,
# and most importantly allows us a pop random elements out of the set
# A queued track must use a list because order is important there - it
# is not here

  cattr_accessor :queue_name do
    "previous_tracks"
  end

  cattr_accessor :minimum_queue_length do
    5
  end


  def self.present?(uri)
    # FIXME Loop through queue
    return false unless $redis.mget self.queue_name
    return $redis.sismember self.queue_name, uri
  end

  def self.enough?
    return $redis.scard(self.queue_name) >= self.minimum_queue_length
  end

  def self.create(uri)
    return false if self.present?(uri)
    $redis.sadd self.queue_name, uri
  end

  def self.next
    $redis.spop self.queue_name
  end
end