class ApplicationController < ActionController::API
  include ActionController::Cookies
  include Pundit::Authorization

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def authenticate_user!
    render json: { error: "Unauthorized" }, status: :unauthorized unless logged_in?
  end

  rescue_from Pundit::NotAuthorizedError do
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
