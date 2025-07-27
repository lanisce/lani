class ApplicationController < ActionController::Base
  include Pundit::Authorization
  
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Pundit: allow NotAuthorizedError to be rescued
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def ensure_onboarding_completed
    return unless user_signed_in?
    return if current_user.onboarding_completed?
    return if controller_name == 'onboarding' || devise_controller?

    redirect_to onboarding_path
  end
end
