# On the Spot

> A Spotify searching and queueing system

### Control Spotify from a web interface!


## About

This application is used at [3months](http://3months.com), to queue and play music in our office. It runs on an iMac here, and works great (so far)


## Setup

1. Clone the application: `git clone git://github.com:joshmcarthur/on-the-spot.git`
2. Pull in dependencies: `bundle install`
3. Add configuration variables to a file named `.env`:

	```
	SPOTIFY_USERNAME="(The Facebook email you want to log in as)"
	SPOTIFY_PASSWORD="(The Facebook password for the account)"
	```
	
4. Start the application by executing: `bundle exec foreman start`. This will run the following processes:
	1. `rails server` (with Thin, runs application)
	2. `spotify_controller` daemon (Plays tracks)
	3. `private_pub` (handles messaging with Faye)
	
## License
[GPL v3](http://opensource.org/licenses/gpl-3.0.html)
  