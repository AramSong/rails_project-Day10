class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :user_signed_in?, :current_user
  
  
  def user_signed_in?
    session[:sign_in_user].present?
  end
  
  #사용자가 요청한 페이지가 원하는대로 동작하지 않을 때
  def authenticate_user!
      redirect_to sign_in_path unless user_signed_in?
  end
  
  def current_user
      @current_user = User.find(session[:sign_in_user]) if user_signed_in?
  end
  
end
