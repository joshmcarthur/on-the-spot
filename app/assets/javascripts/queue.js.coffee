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
}

$ ->
	$('#now_playing i[rel=tooltip]').tooltip(placement: 'bottom')
	PrivatePub.subscribe "/tracks/new", (data, channel) ->
		if data.track
			$('#now_playing > span').text(data.track)
			$('#now_playing').removeClass('hide')
		else if data.stopped
			$('#now_playing').addClass('hide')
