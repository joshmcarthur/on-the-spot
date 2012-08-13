# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#
#= require jquery.spin


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
	processTracks(results.tracks)
	processAlbums(results.albums)

processAlbums = (raw_albums) ->
	albums = []

	for album in raw_albums
		albums.push album unless _.include(albums, album)

	albums = _.map albums, (album) ->
		$("<li></li>")
		.append($('<span></span>').addClass('album').text(album.name))
		.append($('<span></span>').addClass('artist').text(" - #{album.artist}"))
		.data('uri', album.uri)
		.prepend($('<i></i>').addClass('icon-list').attr('title', 'Album'))
		.append($("<button></button>")
			.addClass('btn btn-success play-btn')
			.attr('title', "Play: #{album.name}")
			.append($('<i />').addClass('icon-plus')))

	return if albums.length == 0
	$('#albums').empty()
	_.each albums, (item) ->
		$('#albums').append(item)

	$('.icon-list').tooltip()


processTracks = (raw_tracks) ->
	tracks = []
	for track in raw_tracks
		tracks.push track unless _.include(tracks, track)

	tracks = _.map tracks, (track) ->
		$("<li></li>")
		.append($('<span></span>').addClass('track').text(track.name))
		.append($('<span></span>').addClass('artist').text(" - #{track.artist}")) 
		.append($('<span></span>').addClass('album').text(" (#{track.album})"))
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

	return if collection.length == 0
	$('#tracks').empty()
	_.each collection, (item) -> 
		$('#tracks').append(item)

	$('.icon-music').tooltip()

