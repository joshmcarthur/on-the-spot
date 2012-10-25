require 'spec_helper'

describe PlayerController do

  describe "POST mute" do
    it "should respond with mute" do
      PrivatePub.should_receive(:publish_to).with("/player/status", {:state => "muted"}).and_return(true)
      post :mute
      response.should eq "mute"
    end
  end

  describe "POST unmute" do
    it "should response with unmute" do
      PrivatePub.should_receive(:publish_to).with("/player/status", {:state => "unmuted"}).and_return(true)
      post :unmute
      response.should eq "unmute"
    end
  end


  describe "GET status" do
    context "Player is muted" do
      before :each do
        Sound.mute!
      end

      it "should respond with correct status" do
        get :status
        response.body.should eq "muted"
      end

      it "should not publish a message" do
        PrivatePub.should_not_receive(:publish_to)
        get :status
      end
    end

    context "Player is not muted" do
      before :each do
        Sound.unmute!
      end

      it "should respond with correct status" do
        get :status
        response.body.should eq "unmuted"
      end

      it "should not publish a message" do
        PrivatePub.should_not_receive(:publish_to)
        get :status
      end
    end
  end
end
