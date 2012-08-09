class SearchController < ApplicationController


  def index
    render
  end


  def new
    @results = Rails.cache.fetch "search-for-#{params[:q]}" do
      Hallon::Search.new(params[:q], :tracks => 25)
    end

    respond_to do |format|
      format.json { render :json => @results[:tracks][0..25] }
    end
  end
end
