require 'spec_helper'

describe QueuedTrack do
  let(:track) { "spotify:track:2ViEnnYXmb3Bm0s7XdqWdY" }
  let(:other_track) { "spotify:track:4NFtDCckVMiC2eKwYGoChl" }

  subject do
    QueuedTrack
  end

  before :each do
    $redis.del QueuedTrack.queue_name
  end

  describe "#find" do
    it "should find a valid track" do
      subject.find(track).should be_a(Hallon::Track)
    end

    it "should gracefully fail for an invalid track" do
      subject.find(nil).should be_nil
    end
  end

  describe "#filtered" do
    let(:track) do
      OpenStruct.new.tap do |os|
        os.name = "Test"
        os.artist = OpenStruct.new(:name => "Artist")
      end
    end

    context "filters match track" do
      before do
        OnTheSpot::Application.config.stub!(:track_filters).and_return([ /Test/i ])
      end

      it { subject.filtered?(track).should be_true }
    end

    context "filters do not match track" do
      it { subject.filtered?(track).should be_false }
    end
  end

  describe "#present?" do
    context "the track is present in the queue" do
      before :each do
        subject.create(track)
      end

      it "should return true" do
        subject.present?(track).should be_a(Fixnum)
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
        subject.present?(track).should_not be_false
      end

      it "should return the index of the track" do
        subject.create(track).should be_a(Integer)
      end
    end
  end

  describe "#upvote!" do
    context "track is last in the queue" do
      before do
        subject.create(other_track)
        subject.create(track)
        subject.upvote!(track)
      end

      it "should be first in the queue" do
        subject.index(track).should eq 0
      end

      it "should have pushed the other track to the next position down" do
        subject.index(other_track).should eq 1
      end
    end

    context "track is first in the queue" do
      before do
        subject.create(track)
        subject.create(other_track)
        subject.upvote!(track)
      end

      it "should still be first in the queue" do
        subject.index(track).should eq 0
      end

      it "should not have affected the position of the other track" do
        subject.index(other_track).should eq 1
      end
    end
  end

  describe "#upcoming" do
    before :each do
      subject.create(track)
    end

    it "should return an array of upcoming tracks" do
      subject.upcoming(1).size.should eq 1
      subject.upcoming(1).first.name.should eq subject.find(track).name
    end
  end

  describe "#next" do
    it "should return the next track to play" do
      subject.create(track)
      subject.next.should eq track
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

    let(:loaded_track) { subject.find(track) }

    it "should set the currently playing track" do
      $redis.should_receive(:set).with("currently_playing", track)
      QueuedTrack.play!(track)
    end

    it "should ensure the track is not filtered" do
      QueuedTrack.should_receive(:filtered?).with(loaded_track)
      QueuedTrack.play!(track)
    end

    it "should post a notification that the track is playing" do
      PrivatePub.should_receive(:publish_to).with("/tracks/new",  :track => {:name => loaded_track.name, :image_data => loaded_track.cover_image})
      QueuedTrack.play!(track)
    end

    it "should play the track" do
      $player.should_receive(:play!).and_return(nil)
      QueuedTrack.play!(track)
    end
  end
end