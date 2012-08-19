# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

OnTheSpot.Player =  {
	getStatus: ->
		$.get '/player/status', OnTheSpot.Player.setStatus, 'html'

	setStatus: (new_status) ->
		switch new_status
			when "playing"
				$('i#play_or_pause').attr(title: 'Continue Playback')
				$('i#play_or_pause').removeClass().addClass('icon-pause')
			when "paused" 
				$('i#play_or_pause').attr(title: 'Pause Playback')
				$('i#play_or_pause').removeClass().addClass('icon-play')
			when "stopped"
				$('i#play_or_pause').attr(title: 'No track is queued, or player is not running')
				$('i#play_or_pause').removeClass().addClass('icon-stop look-disabled')


		new_status
}

$ ->
	OnTheSpot.Player.getStatus()
	PrivatePub.subscribe "/player", (data, channel) ->
		OnTheSpot.Player.setStatus(data)
