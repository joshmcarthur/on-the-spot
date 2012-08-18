# http://stackoverflow.com/questions/4536855/integer-ordinalization-in-ruby-rails
require 'active_support/core_ext/integer/inflections'

class QueueController < ApplicationController

  def current
    @current = QueuedTrack.find($redis.get("currently_playing"))
    render :text => @current.try(:name)
  end

  def index
    @current = QueuedTrack.find($redis.get("currently_playing"))
    @next    = QueuedTrack.next(3)
    
    render
  end

  def create
    queued = QueuedTrack.create(params[:uri])
    if queued
      flash.now[:success] = I18n.t('queue.create.success', :position => queued.ordinalize)
    else
      flash.now[:error] = I18n.t('queue.create.failure')
    end

    render
  end
end
