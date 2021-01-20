# frozen_string_literal: true

class LocationsService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    add_location
  rescue StandardError => e
    Rails.logger.error("Error::LocationsService: #{e.message}")
    raise e
  end

  private

  def add_location
    @user.locations.create!(@params)
  end
end
