# frozen_string_literal: true

class LoginService
  def initialize(params:)
    @params = params
  end

  def call
    process_login
  rescue StandardError => e
    Rails.logger.error("Error::LoginService: #{e.message}")
    raise e
  end

  private

  def process_login
    user = User.find_by(email: @params[:email].downcase)

    return false unless user.authenticate(@params[:password])

    user.generate_new_token
    user.save!
    user
  end
end
