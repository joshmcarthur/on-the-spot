unless Rails.env.test?
  OnTheSpot::Application.setup_spotify!
end

Hallon::Player.class_eval do


  def play_with_redis_status(track = nil)
    $redis.set "player_state", "playing" if $redis
    play_without_redis_status(track)
  end

  def pause_with_redis_status
    $redis.set "player_state", "paused" if $redis
    pause_without_redis_status
  end

  def stop_with_redis_status
    $redis.set "player_state", "stopped" if $redis
    stop_without_redis_status
  end

  def status_with_redis_status
    return $redis.get("player_state").to_sym if $redis.try(:get, "player_state")
    return status_without_redis_status
  end

  alias_method_chain :play, :redis_status
  alias_method_chain :pause, :redis_status
  alias_method_chain :stop, :redis_status
  alias_method_chain :status, :redis_status
  
end
