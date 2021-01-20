# frozen_string_literal: true

module Api
  module V1
    class LocationsController < ApplicationController
      def create
        @data = LocationsService.new(user: @current_user, params: location_params).call

        respond_to do |format|
          format.js { head :ok }
          format.json { render json: @data, status: :ok }
        end
      end

      private

      def location_params
        params.permit(:latitude, :longitude, :formatted_address, :street_name, :town, :state, :country, :postal_code, :location_type)
      end
    end
  end
end
