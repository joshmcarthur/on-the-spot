unless Rails.env.test?
  OnTheSpot::Application.setup_spotify!
end
