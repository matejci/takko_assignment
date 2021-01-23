# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class SessionsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = create(:user)
      end

      context 'CREATE' do
        context 'success' do
          should 'return new api_token with other user attributes, upon successful login' do
            post(api_sessions_url, params: { email: @user.email, password: @user.password })

            assert_response(:success)
            assert_includes(response.parsed_body, 'api_token')
          end
        end

        context 'error' do
          should 'return error message if password is wrong' do
            post(api_sessions_url, params: { email: @user.email, password: 'whatever' })

            assert_response(:bad_request)
            assert_includes(response.parsed_body, 'message')
            assert_equal(response.parsed_body['message'], 'Wrong credentials')
          end

          should 'return error message if email is not found' do
            post(api_sessions_url, params: { email: '_________@isp.net', password: 'whatever' })

            assert_response(:not_found)
            assert_includes(response.parsed_body, 'message')
            assert_equal(response.parsed_body['message'], 'Resource not found')
          end
        end
      end

      context 'DELETE' do
        context 'success' do
          should "expire user's api_token" do
            delete(api_session_url, params: {}, headers: { 'Email': @user.email, 'Api-Token': @user.api_token })

            assert_response(:success)
            assert(@user.reload.token_expires_at < Time.current)
          end
        end

        context 'error' do
          should 'return not found error if wrong email is passed' do
            delete(api_session_url, params: {}, headers: { 'Email': '_________@isp.net', 'Api-Token': @user.api_token })

            assert_response(:not_found)
            assert_equal(response.parsed_body['message'], 'Resource not found')
          end

          should 'return unauthorized error if wrong api_token is passed' do
            delete(api_session_url, params: {}, headers: { 'Email': @user.email, 'Api-Token': '123432341323asakdaosdk' })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'return unauthorized error if expired api_token is passed' do
            @user.token_expires_at = 1.day.ago
            @user.save
            @user.reload

            delete(api_session_url, params: {}, headers: { 'Email': @user.email, 'Api-Token': @user.api_token })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'raise bad request error if api_token is missing' do
            delete(api_session_url, params: {}, headers: { 'Email': @user.email })

            assert_response(:bad_request)
          end

          should 'raise bad request error if email is missing' do
            delete(api_session_url, params: {}, headers: { 'Api-Token': @user.api_token })

            assert_response(:bad_request)
          end
        end
      end
    end
  end
end
