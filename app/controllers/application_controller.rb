class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter do |controller|
    require_sitewide_signin unless controller.devise_controller? 
  end
  
  
  def show_404
    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
    return false
  end
  
  protected
  def require_sitewide_signin
    # current_user handles the case where the user is not approved and will redirect them
    unless current_user
      flash[:error] = 'Gotta sign in first!'
      redirect_to new_user_session_path
    end
  end
  
end
