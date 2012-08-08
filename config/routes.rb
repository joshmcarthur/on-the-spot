OnTheSpot::Application.routes.draw do
  resources :search, :only => [:index, :new]
  resources :queue
  root :to => 'search#index'
end