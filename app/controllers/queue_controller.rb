class QueueController < ApplicationController
  def index
    @current = MetaSpotify::Track.lookup($redis.get("currently_playing")) rescue nil
    @next    = []

    (-3..-1).to_a.each do |index|
      track_uri = $redis.lindex("tracks", index)
      next unless track_uri
      @next << Rails.cache.fetch(track_uri) do
        MetaSpotify::Track.lookup(track_uri)
      end
    end

    @next.reverse!
    
    render
  end

  def create
    $redis.lpush "tracks", params[:uri]
    render :nothing => true, :status => :created
  end
end
