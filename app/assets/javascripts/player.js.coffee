# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

OnTheSpot.Player =  {
	getState: ->
		$.get '/player/status', OnTheSpot.Player.setState, 'html'

	setState: (new_state) ->
		switch new_state
			when "muted"
				$('#mute').hide()
				$('#unmute').show()
			when "unmuted"
				$('#mute').show()
				$('#unmute').hide()

		new_state
}

$ ->
	OnTheSpot.Player.getState()
	PrivatePub.subscribe "/player/state", (data, channel) ->
		OnTheSpot.Player.setState(data.state) if data.state
