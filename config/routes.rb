Churchdirectory::Application.routes.draw do
  
  devise_for :users

  root :to => 'churches#index'
  
  resources :churches, :only => [:show, :index] do
    member do 
      post 'update_church_data'
      get 'directory'
      get 'mobile_directory'
      get 'google_kml'
      post 'clear_church_data'
    end
  end

end
