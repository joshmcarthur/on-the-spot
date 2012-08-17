require 'spec_helper'

describe QueueController do
  describe "GET index" do
    it "should return the currently-playing track"

    context "One track queued" do
      it "should return the next queued track"
    end

    context "More than one track queued" do
      it "should return upcoming tracks"
    end
  end

  describe "POST create" do
    context "item is not already queued" do
      it "should add the URI to the queue"
      it "should set a flash message"
      it "should render the correct template"
    end

    context "item is already queued" do
      it "should not add the URI to the queue"
      it "should set a flash message"
      it "should render the correct template"
    end
  end
end
