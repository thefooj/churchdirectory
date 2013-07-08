Churchdirectory::Application.routes.draw do
  
  devise_for :users

  root :to => 'churches#index'
  
  resources :churches, :only => [:show, :index] do
    member do 
      post 'upload_csv'
      get 'upload_csv_form'
      get 'handle_upload_update'
      get 'directory'
      get 'mobile_directory'
      get 'google_kml'
      post 'clear_church_data'
    end
  end

end
