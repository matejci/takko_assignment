# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class LocationsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = create(:user)
        @headers = { 'Email': @user.email, 'Api-Token': @user.api_token }
        @params = { location_type: 'acquired',
                    latitude: 34.052235,
                    longitude: -118.243683,
                    formatted_address: '',
                    street_name: '',
                    town: '',
                    state: '',
                    country: '',
                    postal_code: '',
                    user_ids: '' }
      end

      context 'CREATE' do
        context 'success' do
          should 'return location record with user_ids if request is successful' do
            post(api_locations_url, params: @params, headers: @headers)

            assert_response(:success)
            assert_includes(response.parsed_body, 'user_ids')
            assert_includes(response.parsed_body, 'location_type')
            assert_includes(response.parsed_body, 'latitude')
            assert_includes(response.parsed_body, 'longitude')
            assert_includes(response.parsed_body, 'formatted_address')
            assert_includes(response.parsed_body, 'street_name')
            assert_includes(response.parsed_body, 'town')
            assert_includes(response.parsed_body, 'state')
            assert_includes(response.parsed_body, 'country')
            assert_includes(response.parsed_body, 'postal_code')
          end

          should 'not save params which are not allowed' do
            params = @params
            params[:user_ids] = [100, 200, 300]
            post(api_locations_url, params: params, headers: @headers)

            assert_not_equal(response.parsed_body['user_ids'][0].values, params[:user_ids])
            assert_equal(response.parsed_body['user_ids'][0].values, [@user._id.to_s])
          end
        end

        context 'error' do
          should 'return error message if location_type param is wrong' do
            params = @params
            params[:location_type] = 'wrong type'
            post(api_locations_url, params: params, headers: @headers)

            assert_response(:unprocessable_entity)
            assert_equal(response.parsed_body['message'], 'Validation of Location failed.')
          end

          should 'return error if address params and latitude are missing' do
            params = { location_type: 'acquired', longitude: -118.243683 }
            post(api_locations_url, params: params, headers: @headers)

            assert_response(:unprocessable_entity)
            assert_equal(response.parsed_body['message'], 'Validation of Location failed.')
          end

          should 'return error if address params and longitude are missing' do
            params = { location_type: 'acquired', latitude: 34.052235 }
            post(api_locations_url, params: params, headers: @headers)

            assert_response(:unprocessable_entity)
            assert_equal(response.parsed_body['message'], 'Validation of Location failed.')
          end
        end

        context 'header errors' do
          should 'return not found error if wrong email header is passed' do
            post(api_locations_url, params: @params, headers: { 'Email': '_________@isp.net', 'Api-Token': @user.api_token })

            assert_response(:not_found)
            assert_equal(response.parsed_body['message'], 'Resource not found')
          end

          should 'return unauthorized error if wrong api_token is passed' do
            post(api_locations_url, params: @params, headers: { 'Email': @user.email, 'Api-Token': '123432341323asakdaosdk' })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'return unauthorized error if expired api_token is passed' do
            @user.token_expires_at = 1.day.ago
            @user.save
            @user.reload

            post(api_locations_url, params: @params, headers: { 'Email': @user.email, 'Api-Token': @user.api_token })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'raise bad request error if api_token is missing' do
            post(api_locations_url, params: @params, headers: { 'Email': @user.email })

            assert_response(:bad_request)
          end

          should 'raise bad request error if email is missing' do
            post(api_locations_url, params: @params, headers: { 'Api-Token': @user.api_token })

            assert_response(:bad_request)
          end
        end
      end
    end
  end
end
