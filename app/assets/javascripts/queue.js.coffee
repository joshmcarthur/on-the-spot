# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require private_pub


OnTheSpot.Queue = {
	add: (track_data) ->
		$.post '/queue/',
			track_data,
			->
	getCurrent: ->
		$.get '/queue/current', (track) ->
			return if track == ' '
			OnTheSpot.Queue.setCurrent(track)
		, 'html'

	setCurrent: (track) ->
		$('#now_playing > span').text(track)
		$('#now_playing').removeClass('hide')	
}

$ ->
	$('#now_playing i[rel=tooltip]').tooltip(placement: 'bottom')
	OnTheSpot.Queue.getCurrent()
	PrivatePub.subscribe "/tracks/new", (data, channel) ->
		if data.track
			OnTheSpot.Queue.setCurrent(data.track)
		else if data.stopped
			$('#now_playing').addClass('hide')
