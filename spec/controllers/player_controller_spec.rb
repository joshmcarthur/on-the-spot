require 'spec_helper'

describe PlayerController do

  before :each do
    # Prevent the player from playing or pausing
    Spotify.stub!(:session_player_play)
    PrivatePub.stub!(:publish_to)
  end

  describe "POST play_or_pause" do
    context "player is playing" do
      before :each do
        $player.stub!(:status).and_return(:playing, :paused)
      end

      it "should pause the track" do
        $player.should_receive(:pause)
        post :play_or_pause
      end

      it "should return the new player status" do
        post :play_or_pause
        response.body.should eq "paused"
      end
    end

    context "player is paused" do
      before :each do
        $player.stub!(:status).and_return(:paused, :playing)
      end

      it "should play the track" do
        $player.should_receive(:play)
        post :play_or_pause
      end

      it "should return the new player status" do
        post :play_or_pause
        response.body.should eq "playing"
      end
    end

    context "player is stopped" do
      before :each do
        $player.stub!(:status).and_return(:stopped, :playing)
      end

      it "should play the track" do
        $player.should_receive(:play)
        post :play_or_pause
      end

      it "should retern the new player status" do
        post :play_or_pause
        response.body.should eq "playing"
      end
    end
  end
end
