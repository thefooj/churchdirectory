class ApplicationController < ActionController::Base
  protect_from_forgery
  
  
  def show_404
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    return false
  end
end
