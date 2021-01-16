# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  API_TOKEN = 'Api-Token'
  EMAIL = 'email'

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found

  before_action :authenticate_user, :destroy_session
  helper_method :current_user, :user_logged_in? # so it can be used inside views/helpers

  def current_user
    @current_user ||= User.where(api_token: request.headers[API_TOKEN]).first
  end

  def user_logged_in?
    !token_expired?(current_user)
  end

  private

  def authenticate_user
    return bad_request unless request.headers[API_TOKEN] && request.headers[EMAIL]

    user = User.find_by(email: request.headers[EMAIL].downcase)
    return unauthorized unless token_valid?(user)

    @current_user = user
  end

  def not_found
    head :not_found
  end


  # disabling CSRF token and cookies
  def destroy_session
    request.session_options[:skip] = true
  end

  def bad_request
    head :bad_request
  end

  def token_valid?(user)
    is_match?(user) && !token_expired?(user)
  end

  def is_match?(user)
    # instead of just comparing DB token with the one from the header, let's use 'secure compare' to avoid timing attacks
    ActiveSupport::SecurityUtils.secure_compare(user.api_token, request.headers[API_TOKEN])
  end

  def token_expired?(user)
    return true unless user

    DateTime.parse(user.token_expires_at) < Time.current
  end

  def unauthorized
    render json: { message: 'Token expired, or wrong credentials' }, status: :unauthorized
  end
end
