class PlayerController < ApplicationController

  def mute
    Sound.mute!
    respond_with_state_change
  end

  def unmute!
    Sound.unmute!
    respond_with_state_change
  end

  def status
    render :nothing => true
    #respond_with_state_change(false) and return
  end

  private

  def respond_with_state_change(broadcast = true)
    $redis.get("sound_state").tap do |state|
      render :text => state
      PrivatePub.publish_to "/player/state", state if broadcast
    end
  end

end
