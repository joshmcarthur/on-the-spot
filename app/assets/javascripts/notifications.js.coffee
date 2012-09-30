OnTheSpot.Notification = {
	setup: ->
		window.notifications = window.webkitNotifications unless window.notifications
		if window.notifications && window.notifications.checkPermission() == 0
			OnTheSpot.Notification.supported = true
		else
			OnTheSpot.Notification.supported = false

	requestAccess: ->
		window.notifications.requestPermission();

	trackPlaying: (track) ->
		return unless OnTheSpot.Notification.supported == true && track

		window.notifications.createNotification(
			'/assets/apple-touch-icon-precomposed.png', 
			track.name,
			'On the Spot :: Track Playing'
		).show()
}
