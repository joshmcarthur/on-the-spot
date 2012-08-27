require 'spec_helper'

describe PlayerController do

  before :each do
    # Prevent the player from playing or pausing
    Spotify.stub!(:session_player_play)
    PrivatePub.stub!(:publish_to)
  end

  describe "POST mute" do
    it "should respond with mute" do
      post :mute
      response.should eq "mute"
    end
  end

  describe "POST unmute" do
    it "should response with unmute" do
      post :unmute
      response.should eq "unmute"
    end
  end

  describe "GET status" do
    it "should respond with unmute" do
      get :status
      response.should eq "unmute"
    end
  end
end
