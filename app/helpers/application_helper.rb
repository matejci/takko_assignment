# frozen_string_literal: true

module ApplicationHelper
  def user_logged?
    current_user.present?
  end
end
