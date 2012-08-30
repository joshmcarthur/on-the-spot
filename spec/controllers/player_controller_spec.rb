require 'spec_helper'

describe PlayerController do

  describe "POST mute" do
    it "should respond with mute" do
      PrivatePub.should_receive(:publish_to).with("/player/status", "muted").and_return(true)
      post :mute
      response.should eq "mute"
    end
  end

  describe "POST unmute" do
    it "should response with unmute" do
      PrivatePub.should_receive(:publish_to).with("/player/status", "unmuted").and_return(true)
      post :unmute
      response.should eq "unmute"
    end
  end


end
