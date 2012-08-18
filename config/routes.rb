OnTheSpot::Application.routes.draw do
  resources :search, :only => [:index, :new]
  resources :queue do
    get :current, :on => :collection
  end

  
  root :to => 'search#index'
end