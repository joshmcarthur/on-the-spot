OnTheSpot::Application.routes.draw do
  resources :search, :only => [:index, :new]
  resources :queue do
    get :current, :on => :collection
    delete :clear, :on => :collection
  end

  resource :player, :only => [], :controller => 'player' do
    post :mute
    post :unmute
    get :status
  end
  
  root :to => 'search#index'
end