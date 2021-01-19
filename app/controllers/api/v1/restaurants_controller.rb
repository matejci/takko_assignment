# frozen_string_literal: true

module Api
  module V1
    class RestaurantsController < ApplicationController
      def search
        @data = SearchService.new(user: @current_user, params: search_params).call

        respond_to do |format|
          format.js { render 'home/search.js.erb' }
          format.json { render json: @data, status: :ok }
        end
      end

      def preference
        byebug
        @data = UpdatePreferenceService.new(user: @current_user, params: preference_params).call

        respond_to do |format|
          format.js { head :ok }
          format.json { render json: @data, status: :ok }
        end
      end

      private

      def search_params
        params.permit(:term, :address, :postal_code)
      end

      def preference_params
        params.permit(:categories, :vote)
      end
    end
  end
end
