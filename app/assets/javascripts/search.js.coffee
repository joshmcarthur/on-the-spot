# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#


$ ->
	searchFromParams()

	$('.play-btn').live 'click', ->
		row = $(this).closest('li')

		if trackDangerZone(row)
			if confirm("Woah, looks like a karaoke track you've got there. Are you sure?")
				OnTheSpot.Queue.add({name: row.text(), uri: row.data('uri')})
		else
			OnTheSpot.Queue.add({name: row.text(), uri: row.data('uri')})

	$('#controls a').tooltip(placement: 'bottom')

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
	$('.spinner').removeClass('hide')

hideActivity = ->
	$('.spinner').addClass('hide')

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

trackDangerZone = (track_row) ->
	danger_rows = track_row.filter ->
		/karaoke/gi.test $(this).text()

	return danger_rows.length > 0

searchFromParams = ->
	if search = $.parseParams(window.location.search.split('?')[1]).q
		$('input#search').val(search)
		# Changing val doesn't seem to trigger the keyup
		setTimeout("$('input#search').trigger('keyup')", 500)


