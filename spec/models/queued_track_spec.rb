require 'spec_helper'

describe QueuedTrack do
  let(:track) { "spotify:track:2ViEnnYXmb3Bm0s7XdqWdY" }
  subject do
    QueuedTrack
  end

  before :each do
    $redis.del "play_queue"
  end

  describe "#find" do
    it "should find a valid track" do
      subject.find(track).should be_a(Hallon::Track)
    end

    it "should gracefully fail for an invalid track" do
      subject.find(nil).should be_nil
    end
  end

  describe "#present?" do
    context "the track is present in the queue" do
      before :each do
        subject.create(track)
      end

      it "should return true" do
        subject.present?(track).should be_true
      end
    end

    context "the track is not present in the queue" do
      it "should return false" do
        subject.present?(track).should be_false
      end
    end
  end

  describe "#create" do
    context "track already queued" do
      before :each do
        subject.create(track)
      end

      it "should return false" do
        subject.create(track).should be_false
      end
    end

    context "track is not already queued" do
      it "should add the track to the queue" do
        subject.create(track)
        subject.present?(track).should be_true
      end

      it "should return the index of the track" do
        subject.create(track).should be_a(Integer)
      end
    end
  end

  describe "#next" do
    before :each do
      subject.create(track)
    end

    it "should return an array of upcoming tracks" do
      subject.next(1).size.should eq 1
      subject.next(1).first.name.should eq subject.find(track).name
    end
  end

  describe "#stop!" do
    it "should clear the currently playing track" do
      $redis.should_receive(:del).with("currently_playing")
      QueuedTrack.stop!
    end

    it "should stop the player" do
      $player.should_receive(:stop).and_return(nil)
      QueuedTrack.stop!
    end
  end

  describe "#play!" do
    before :each do
      PrivatePub.stub!(:publish_to)
      $player.stub(:play!)
    end

    it "should set the currently playing track" do
      $redis.should_receive(:set).with("currently_playing", track)
      QueuedTrack.play!(track)
    end

    it "should post a notification that the track is playing" do
      PrivatePub.should_receive(:publish_to).with("/tracks/new", {:track => subject.find(track).name})
      QueuedTrack.play!(track)
    end

    it "should play the track" do
      $player.should_receive(:play!).and_return(nil)
      QueuedTrack.play!(track)
    end
  end
end