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
    categories_from_params = @params[:categories].split(', ')

    categories_from_params.each do |cfp|
      if @user.categories.key?(cfp)
        @user.categories[cfp] += parse_vote
      else
        @user.categories[cfp] = parse_vote
      end
    end

    @user.save!
  end

  def parse_vote
    @params[:vote] == 'false' ? -1 : 1
  end
end
