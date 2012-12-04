# Set track filters to prevent certain songs from being queued
# This is because Spotify has a lot of songs that aren't actually
# what we want - for example instrumental or karaoke version
OnTheSpot::Application.config.track_filters = [
  /Karaoke/i,
  /Instrumental/i
]