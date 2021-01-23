# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  API_TOKEN = 'Api-Token'
  EMAIL = 'Email'

  rescue_from Mongoid::Errors::DocumentNotFound, with: :not_found
  rescue_from Mongoid::Errors::Validations, with: :unprocessable_entity
  rescue_from SearchService::ExternalServiceError, with: :external_service_error

  before_action :authenticate_user, :destroy_session
  helper_method :current_user, :user_logged_in? # so it can be used inside views/helpers

  def current_user
    @current_user ||= User.find_by(api_token: request.headers[API_TOKEN])
  end

  def user_logged_in?
    token_valid?(current_user)
  end

  private

  def authenticate_user
    return bad_request unless request.headers[API_TOKEN] && request.headers[EMAIL]

    user = User.find_by(email: request.headers[EMAIL].downcase)

    return unauthorized unless token_valid?(user)

    @current_user = user
  end

  def not_found
    respond_to do |format|
      format.js { render 'errors/not_found.js.erb' }
      format.json { render json: { message: 'Resource not found' }, status: :not_found }
    end
  end

  # disabling CSRF token and cookies
  def destroy_session
    request.session_options[:skip] = true
  end

  def bad_request
    head :bad_request
  end

  def token_valid?(user)
    token_match?(user) && !token_expired?(user)
  end

  def token_match?(user)
    # instead of just comparing DB token with the one from the header, let's use 'secure compare' to avoid timing attacks
    ActiveSupport::SecurityUtils.secure_compare(user.api_token, request.headers[API_TOKEN])
  end

  def token_expired?(user)
    return true unless user

    Time.current > DateTime.parse(user.token_expires_at)
  end

  def unauthorized
    respond_to do |format|
      format.js { render 'errors/unauthorized.js.erb' }
      format.json { render json: { message: 'Token expired, or wrong credentials' }, status: :unauthorized }
    end
  end

  def external_service_error
    respond_to do |format|
      format.js { render 'errors/external_service_error.js.erb' }
      format.json { render json: { message: 'External Service Error or Location unsupported' }, status: :unprocessable_entity }
    end
  end

  def unprocessable_entity(error)
    respond_to do |format|
      format.js { render 'errors/unprocessable_entity.js.erb', locals: { error: error&.problem } }
      format.json { render json: { message: error.problem }, status: :unprocessable_entity }
    end
  end
end
