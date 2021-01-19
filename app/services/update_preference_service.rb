# frozen_string_literal: true

class UpdatePreferenceService
  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    update_categories
  rescue StandardError => e
    Rails.logger.error("Error::UpdatePreferenceService: #{e.message}")
    raise e
  end

  private

  def update_categories
    # @user.categories
  end
end
