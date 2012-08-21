# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'

require 'simplecov'
SimpleCov.start 'rails'
require 'fakeredis/rspec'

require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.before do
    # FIXME - Track currently makes a new FFI Memory Pointer
    # in it's constructor (which I can't stub out), and so
    # I need to replace it with a double.
    # This results in warnings about uninitialized constants, 
    # but does allow the tests to run without a full-blown
    # Spotify environment setup
    hallon_track = double("Hallon::Track").as_null_object
    Hallon::Track = hallon_track

    session_instance = OpenStruct.new(:pointer => "Pointer")
    session_instance.stub(:on).and_return(nil)

    Hallon::AudioQueue.any_instance.stub(:new_cond).and_return(OpenStruct.new)

    Hallon::Session.stub(:instance?).and_return(true)
    Hallon::Session.stub(:instance).and_return(session_instance)
    OnTheSpot::Application.setup_spotify!
  end

  config.before(:each) do
    $player.stub(:play!)
    $player.stub(:load)
    Hallon::Track.any_instance.stub(:load).and_return(OpenStruct.new({:name => "Hurt Feelings"}))
  end


  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"
end
