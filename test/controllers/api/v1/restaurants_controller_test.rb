# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class RestaurantsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = create(:user)
        @headers = { 'Email': @user.email, 'Api-Token': @user.api_token }
        @params = { categories: 'chinese, asian', vote: 'true' }
      end

      context 'PREFERENCE' do
        context 'success' do
          should 'return status ok and empty response object if request is successful' do
            post(api_preference_url, params: @params, headers: @headers)

            assert_response(:success)
            assert_equal(response.body, '')
          end

          should 'not update categories if vote param is not allowed but request is successful' do
            categories_before_request = @user.categories

            params = @params
            params[:vote] = true

            post(api_preference_url, params: params, headers: @headers)

            assert_response(:success)

            categories_after_request = @user.categories

            assert_equal(categories_before_request, categories_after_request)
          end

          should 'not update categories if categories param is not correct type but request is successful' do
            categories_before_request = @user.categories

            params = @params
            params[:categories] = true

            post(api_preference_url, params: params, headers: @headers)

            assert_response(:success)

            categories_after_request = @user.categories

            assert_equal(categories_before_request, categories_after_request)
          end
        end

        context 'error' do
          should 'return error message in response body and 422 status code if user data is compromised' do
            @user.name = nil
            @user.save(validate: false)
            @user.reload

            post(api_preference_url, params: @params, headers: @headers)

            assert_response(:unprocessable_entity)
            assert_equal(response.parsed_body['message'], 'Validation of User failed.')
          end
        end

        context 'header errors' do
          should 'return not found error if wrong email header is passed' do
            post(api_preference_url, params: @params, headers: { 'Email': '_________@isp.net', 'Api-Token': @user.api_token })

            assert_response(:not_found)
            assert_equal(response.parsed_body['message'], 'Resource not found')
          end

          should 'return unauthorized error if wrong api_token is passed' do
            post(api_preference_url, params: @params, headers: { 'Email': @user.email, 'Api-Token': '123432341323asakdaosdk' })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'return unauthorized error if expired api_token is passed' do
            @user.token_expires_at = 1.day.ago
            @user.save
            @user.reload

            post(api_preference_url, params: @params, headers: { 'Email': @user.email, 'Api-Token': @user.api_token })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'raise bad request error if api_token is missing' do
            post(api_preference_url, params: @params, headers: { 'Email': @user.email })

            assert_response(:bad_request)
          end

          should 'raise bad request error if email is missing' do
            post(api_preference_url, params: @params, headers: { 'Api-Token': @user.api_token })

            assert_response(:bad_request)
          end
        end
      end

      context 'SEARCH' do
        context 'success' do

        end
      end
    end
  end
end
