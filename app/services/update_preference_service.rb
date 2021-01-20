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
    return unless @params[:categories].present? && @params[:vote].in?(%w[false true])

    @params[:categories].split(', ').each do |cfp|
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
