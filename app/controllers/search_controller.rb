class SearchController < ApplicationController

  def index
    render
  end

  def new
    @results = Rails.cache.fetch "search-for-#{params[:q]}" do
      Hallon::Search.new(params[:q], :tracks => 25, :tracks_offset => 10).load.tracks.to_a.map do |track|
        {
          :name => track.name, 
          :artist => track.artists.first.name, 
          :album => track.album.name, 
          :popularity => track.popularity, 
          :uri => track.to_link.to_str
        }
      end
    end

    respond_to do |format|
      format.json { render :json => @results }
    end
  end
end
