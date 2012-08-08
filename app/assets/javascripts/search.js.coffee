# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery.masonry

$ ->
	$('.play-btn').tooltip()
	$('.play-btn').live 'click', ->
		row = $(this).closest('li')
		OnTheSpot.Queue.add({name: row.text(), uri: row.data('uri')})

	$('input#search').keyup (event) ->
		query = $(this).val()
		return if query.length < 5

		$.getJSON(
			'/search/new',
			{q: query},
			handleSearchResults
		)


handleSearchResults = (results) ->
	tracks = []
	artists = []
	albums = []

	for track in results
		track_key = {name: track.name, popularity: track.popularity, uri: track.uri}

		tracks.push track_key unless _.include(tracks, track_key)

	tracks = _.map tracks, (track) ->
		$("<li></li>")
		.text(track.name)
		.data('popularity', track.popularity)
		.data('uri', track.uri)
		.prepend($('<i></i>').addClass('icon-music'))
		.append($("<button></button>")
			.addClass('btn btn-success play-btn')
			.attr('title', "Play: #{track.name}")
			.append($('<i />').addClass('icon-plus')))


	collection = _.sortBy tracks.concat(artists).concat(albums), (item) ->
		return 0 unless item.data('popularity')
		return Math.round(1 - item.data('popularity'))

	return if collection.length == 0
	$('#tracks').empty()
	_.each collection, (item) -> 
		$('#tracks').append(item)

