# frozen_string_literal: true

module Api
  module V1
    class SessionsController < ApplicationController
      skip_before_action :authenticate_user, only: :create

      def create
        @login_results = LoginService.new(params: login_params).call

        respond_to do |format|
          format.js { render 'sessions/create.js.erb' }
          format.json { json_response }
        end
      end

      def destroy
        User.find_by!(email: request.headers[EMAIL]).update_attributes!(token_expires_at: 1.hour.ago)
        head :ok
      end

      private

      def login_params
        params.permit(:email, :password)
      end

      def json_response
        if @login_results&.dig(:data)
          render json: @login_results.dig(:data), except: %i[password_digest location_ids created_at updated_at], status: :ok
        else
          render json: { message: 'Wrong credentials' }, status: :bad_request
        end
      end
    end
  end
end
