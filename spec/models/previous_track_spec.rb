require 'spec_helper'

describe PreviousTrack do
  let(:track) { "spotify:track:2ViEnnYXmb3Bm0s7XdqWdY" }

	subject do
		PreviousTrack
	end

  before :each do
    $redis.del "previous_tracks"
  end

  describe "#enough?" do
    before :each do
      subject.minimum_queue_length = 1
    end

    context "there are enough items in the queue" do
      before :each do
        subject.create track
      end

      it "should return true" do
        subject.enough?.should be_true
      end
    end

    context "there are not enough items in the queue" do
      it "should return false" do
        subject.enough?.should be_false
      end
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
        subject.create(track).should be_true
      end
    end
  end

  describe "#next" do
    it "should return the next track to play" do
      subject.create(track)
      subject.next.should eq track
    end
  end
end