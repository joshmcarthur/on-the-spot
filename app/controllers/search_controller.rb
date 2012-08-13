class SearchController < ApplicationController

  def index
    render
  end

  def new
    @results = Rails.cache.fetch "search-for-#{params[:q]}" do
      search = Hallon::Search.new(params[:q], :tracks => 25, :albums => 5).load
      {
        :tracks => search.tracks.to_a.map { |track|
          {
            :name => track.name,
            :artist => track.artists.first.name,
            :album => track.album.name,
            :popularity => track.popularity,
            :uri => track.to_link.to_str
          }
        },
        :albums => search.albums.to_a.map { |album|
          {
            :name => album.name,
            :artist => album.artist.name,
            :uri => album.to_link.to_str
          }
        }
      }
    end

    respond_to do |format|
      format.json { render :json => @results }
    end
  end
end
