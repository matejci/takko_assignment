# frozen_string_literal: true

module ApplicationHelper
  def user_logged?
    current_user.present?
  end

  def format_distance(distance)
    "#{(distance / 1600).round(2)} miles"
  end
end
