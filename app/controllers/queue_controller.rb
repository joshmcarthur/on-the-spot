# http://stackoverflow.com/questions/4536855/integer-ordinalization-in-ruby-rails
require 'active_support/core_ext/integer/inflections'

class QueueController < ApplicationController
  def index
    @current = MetaSpotify::Track.lookup($redis.get("currently_playing")) rescue nil
    @next    = []

    (-3..-1).to_a.each do |index|
      track_uri = $redis.lindex("play_queue", index)
      next unless track_uri
      @next << Rails.cache.fetch(track_uri) do
        MetaSpotify::Track.lookup(track_uri)
      end
    end

    @next.reverse!
    
    render
  end

  def create
    position = $redis.lpush "play_queue", params[:uri]
    flash.now[:notice] = I18n.t('queue.create.success', :position => position.ordinalize)
    render :status => :created
  end
end
