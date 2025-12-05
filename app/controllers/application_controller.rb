class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  respond_to :json

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_default_response_format

  rescue_from ActiveRecord::RecordNotFound do
    render json: { error: 'Not Found' }, status: :not_found
  end

  protected

  def set_default_response_format
    request.format = :json unless request.format
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
  end

  # Custom JWT authentication method
  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    decoded = JsonWebToken.decode(token)
    
    if decoded
      @current_user = User.find_by(id: decoded[:user_id])
      unless @current_user
        render json: { error: 'Unauthorized' }, status: :unauthorized
        return
      end
    else
      render json: { error: 'Invalid or expired token' }, status: :unauthorized
      return
    end
  end

  def current_user
    @current_user ||= begin
      token = request.headers['Authorization']&.split(' ')&.last
      decoded = JsonWebToken.decode(token)
      User.find_by(id: decoded[:user_id]) if decoded
    end
  end
end
