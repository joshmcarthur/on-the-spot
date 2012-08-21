unless Rails.env.test?
  OnTheSpot::Application.setup_spotify!
end

Hallon::Player.class_eval do
  alias_method_chain :play_with_redis_status
  alias_method_chain :pause_with_redis_status
  alias_method_chain :stop_with_redis_status

  def play_with_redis_status
    $redis.set "player_state", "playing" if $redis
    play_without_redis_status
  end

  def pause_with_redis_status
    $redis.set "player_state", "paused" if $redis
    pause_without_redis_status
  end

  def stop_with_redis_status
    $redis.set "player_state", "stopped" if $redis
    stop_without_redis_status
  end
  
end
