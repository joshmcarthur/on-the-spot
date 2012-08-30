class PlayerController < ApplicationController

  def mute
    Sound.mute!
    respond_with_state_change
  end

  def unmute
    Sound.unmute!
    respond_with_state_change
  end

  def status
    render :nothing => true
    respond_with_state_change(false)
  end

  private

  def respond_with_state_change(broadcast = true)
    state = $redis.get("sound_state")
    PrivatePub.publish_to "/player/state", state if broadcast
    render :text => state and return
  end

end
