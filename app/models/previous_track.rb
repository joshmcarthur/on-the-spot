class PreviousTrack
  @@queue_name = "previous_tracks"

  def self.present?(uri)
    # FIXME Loop through queue
    return false unless $redis.mget @@queue_name.compact
    $redis.lrange(@@queue_name, 0, -1).each do |value|
      return true if value == uri
    end

    return false
  end

  def self.create(uri)
    return false if self.present?(uri)
    return $redis.rpush @@queue_name, uri
  end

  def self.next
    $redis.lpop @@queue_name
  end

end