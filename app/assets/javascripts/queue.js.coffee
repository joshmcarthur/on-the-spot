# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#


OnTheSpot.Queue = {
	add: (track_data) ->
		$.post '/queue/',
			track_data,
			->
				alert('Added!')
}

