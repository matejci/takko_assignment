# frozen_string_literal: true

class LoginService
  def initialize(params:)
    @params = params
  end

  def call
    process_login
  end

  private

  def process_login
    user = User.where(email: @params[:email].downcase).first # using #where, because I don't want to raise exception here if nothing is found
    user&.authenticate(@params[:password])
  end
end
