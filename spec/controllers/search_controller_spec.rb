require 'spec_helper'

describe SearchController do

  describe "GET index" do
    it "renders the index template" do
      get :index
      response.should render_template "index"
    end
  end

  describe "GET new" do
    it "should perform the search and return results" do
      get :new, :q => "artist:\"Flight of the Conchords\""
      assigns(:results)[:tracks].should be_a(Array)
    end

    describe "Data structure" do
      before :each do
        get :new, :q => "artist:\"Flight of the Conchords\""
        @data = assigns(:results)[:tracks]
        @datum = @data.first
      end

      it "should have a collection of tracks" do
        @data.should_not be_empty
      end

      it "should have a track name" do
        @datum[:name].should be_a String
      end

      it "should have an artist" do
        @datum[:artist].should match "Flight Of The Conchords"
      end

      it "should have an album" do
        @datum[:album].should be_a String
      end

      it "should have a numerical popularity" do
        @datum[:popularity].should be_between(1, 100)
      end

      it "should have a string duration" do
        @datum[:duration].should match /\A[0-9]{1,2}\m\s{1}[0-9]{2}s\Z/
      end

      it "should have a Spotify URI" do 
        URI.parse(@datum[:uri]).scheme.should eq "spotify"
      end
    end
  end
end
