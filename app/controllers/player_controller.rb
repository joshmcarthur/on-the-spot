class PlayerController < ApplicationController

  def play_or_pause

    case $player.status
      when :playing
        $player.pause
      when :paused
        $player.play
    end

    render :text => $player.status
    PrivatePub.publish_to "/player", $player.status
  end

  def status
    render :text => $player.status
  end

end
