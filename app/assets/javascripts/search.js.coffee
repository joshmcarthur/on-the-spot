# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#


$ ->
	$('.play-btn').live 'click', ->
		row = $(this).closest('li')
		OnTheSpot.Queue.add({name: row.text(), uri: row.data('uri')})
	$('#controls a').tooltip(placement: 'right')

	$('a.search_example').click autofillSearch

	$('input#search').on 'search_changed', ->
		query = $(this).val()
		$('#tracks').empty() if query.length < 1
		return if query.length < 5

		if OnTheSpot.searching == true
			return
		else
			OnTheSpot.searching = true

		showActivity()

		$.getJSON(
			'/search/new',
			{q: query},
			(results) ->
				handleSearchResults(results)
				OnTheSpot.searching = false
		)



	$('input#search').keyup (event) ->
		setTimeout("$('input#search').trigger('search_changed')", 1000)

autofillSearch = (event) ->
	event.preventDefault()
	event.stopPropagation()

	$('input#search').val $(event.target).text()
	$('input#search').trigger('keyup')
	$('.modal').modal('hide')

showActivity = ->
	$('.spinner').removeClass('hidden')

hideActivity = ->
	$('.spinner').addClass('hidden')

handleSearchResults = (results) ->
	processTracks(results.tracks)


processTracks = (raw_tracks) ->
	tracks = []
	for track in raw_tracks
		tracks.push track unless _.include(tracks, track)

	tracks = _.map tracks, (track) ->
		$("<li></li>")
		.append($('<span></span>').addClass('track').text(track.name))
		.append($('<span></span>').addClass('artist').text(" - #{track.artist}")) 
		.append($('<span></span>').addClass('album').text(" (#{track.album})"))
		.append($('<span></span>').addClass('duration').text(" - #{track.duration}"))
		.data('popularity', track.popularity)
		.data('uri', track.uri)
		.prepend($('<i></i>').addClass('icon-music').attr('title', 'Track'))
		.append($("<button></button>")
			.addClass('btn btn-success play-btn')
			.attr('title', "Play: #{track.name}")
			.append($('<i />').addClass('icon-plus')))

	collection = _.sortBy tracks, (item) ->
		return 1000 unless item.data('popularity')
		console.log "Track: #{item.find('.track').text()}, popularity: #{(100 - item.data('popularity'))}"
		return 100 - item.data('popularity')

	hideActivity()

	return if collection.length == 0
	$('#tracks').empty()
	_.each collection, (item) -> 
		$('#tracks').append(item)


	$('.icon-music').tooltip()


