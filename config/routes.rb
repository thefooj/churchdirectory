Churchdirectory::Application.routes.draw do
  
  root :to => 'churches#index'
  
  resources :churches, :only => [:show, :index] do
    member do 
      post 'update_church_data'
      get 'directory'
    end
  end

end
