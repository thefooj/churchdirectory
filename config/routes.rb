Churchdirectory::Application.routes.draw do
  
  root :to => 'churches#index'
  
  resources :churches, :only => [:show, :index] do
    member do 
      put 'update_church_data'
    end
  end

end
