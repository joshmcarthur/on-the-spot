class SearchController < ApplicationController


  def index
    render
  end


  def new
    @results = Rails.cache.fetch "search-for-#{params[:q]}" do
      MetaSpotify::Track.search(params[:q])
    end

    respond_to do |format|
      format.json { render :json => @results[:tracks][0..25] }
    end
  end
end
