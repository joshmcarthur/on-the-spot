$hallon_session = Hallon::Session.initialize IO.read(Rails.root.join('config', 'keys', 'spotify_appkey.key'))
$hallon_session.login! ENV['SPOTIFY_USERNAME'], ENV['SPOTIFY_PASSWORD']

$player = Hallon::Player.new(Hallon::OpenAL)
$player.volume_normalization = true