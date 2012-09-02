require 'spec_helper'

describe QueueController do
  let(:track_uri) { "spotify:track:2ViEnnYXmb3Bm0s7XdqWdY" }
  
  let(:track_one) { "spotify:track:1CDqOWVW4XggJv4aSjxZLg" }
  let(:track_two) { "spotify:track:0RlygkwmzYlFSZ5ydtDgKU" }
  let(:track_three) { "spotify:track:4NFtDCckVMiC2eKwYGoChl" }

  before :each do
    $redis.del "currently_playing"
    $redis.del "play_queue"
  end

  describe "GET current" do
    it "should return the currently playing track when one is playing" do
      $redis.set "currently_playing", track_uri
      get :current
      response.body.should eq QueuedTrack.find(track_uri).name
    end

    it "should return an empty string when no track is playing"  do
      get :current
      response.body.should be_blank
    end
  end

  describe "GET index" do
    it "should return the currently-playing track" do
      $redis.set "currently_playing", track_uri
      get :index
      assigns(:current).uri.should eq track_uri
    end

    it "should render the index template" do
      get :index
      response.should render_template "index"
    end

    context "One track queued" do
      it "should return the next queued track" do
        QueuedTrack.create(track_one)
        get :index
        assigns(:next).should have(1).things
        assigns(:next).first.uri.should eq track_one
      end
    end

    context "More than one track queued" do
      it "should return upcoming tracks in FIFO order" do
        QueuedTrack.create(track_one)
        QueuedTrack.create(track_two)
        QueuedTrack.create(track_three)
        get :index
        assigns(:next).should have(3).things
        assigns(:next).all? { |n| [track_one, track_two, track_three].include?(n.uri) }
      end
    end
  end

  describe "POST create" do
    context "item is not already queued" do
      before :each do
        post :create, :uri => track_uri, :format => :js
      end

      it "should add the URI to the queue" do
        QueuedTrack.present?(track_uri).should be_true
      end

      it "should set a flash message" do
        flash.now[:success].should eq I18n.t('queue.create.success', :position => '1st')
      end

      it "should render the correct template" do
        response.should render_template "create"
      end
    end

    context "item is already queued" do
      before :each do
        QueuedTrack.create(track_uri)
        @list_length = $redis.llen("play_queue")
        post :create, :uri => track_uri, :format => :js
      end

      it "should not add the URI to the queue again" do
        $redis.llen("play_queue").should eq @list_length
      end

      it "should set a flash message" do
        flash.now[:error].should eq I18n.t('queue.create.failure')
      end

      it "should render the correct template" do
        response.should render_template "create"
      end
    end
  end

  describe "DELETE clear" do
    before :each do
      QueuedTrack.create(track_uri)
      delete :clear
    end

    it "should stop the player" do
      $player.status.should eq :stopped
    end

    it "should clear the play queue" do
      $redis.llen("play_queue").should eq 0
    end

    it "should set a flash message" do
      flash.now[:success].should eq I18n.t('queue.clear.success')
    end

    it "should redirect to the correct path" do
      response.should redirect_to root_path
    end
  end
end
