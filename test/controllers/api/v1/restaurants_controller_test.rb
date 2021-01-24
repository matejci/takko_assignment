# frozen_string_literal: true

require 'test_helper'

module Api
  module V1
    class RestaurantsControllerTest < ActionDispatch::IntegrationTest
      setup do
        @user = create(:user)
        @headers = { 'Email': @user.email, 'Api-Token': @user.api_token }
        @preference_params = { categories: 'chinese, asian', vote: 'true' }
        @search_params = { term: 'pizza', address: '892 ARLENE WAY, NOVATO, CA, USA', postal_code: '' }
      end

      context 'PREFERENCE' do
        context 'success' do
          should 'return status ok and empty response object if request is successful' do
            post(api_preference_url, params: @preference_params, headers: @headers)

            assert_response(:success)
            assert_equal(response.body, '')
          end

          should 'not update categories if vote param is not allowed but request is successful' do
            categories_before_request = @user.categories

            params = @preference_params
            params[:vote] = true

            post(api_preference_url, params: params, headers: @headers)

            assert_response(:success)

            categories_after_request = @user.categories

            assert_equal(categories_before_request, categories_after_request)
          end

          should 'not update categories if categories param is not correct type but request is successful' do
            categories_before_request = @user.categories

            params = @preference_params
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

            post(api_preference_url, params: @preference_params, headers: @headers)

            assert_response(:unprocessable_entity)
            assert_equal(response.parsed_body['message'], 'Validation of User failed.')
          end
        end

        context 'header errors' do
          should 'return not found error if wrong email header is passed' do
            post(api_preference_url, params: @preference_params, headers: { 'Email': '_________@isp.net', 'Api-Token': @user.api_token })

            assert_response(:not_found)
            assert_equal(response.parsed_body['message'], 'Resource not found')
          end

          should 'return unauthorized error if wrong api_token is passed' do
            post(api_preference_url, params: @preference_params, headers: { 'Email': @user.email, 'Api-Token': '123432341323asakdaosdk' })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'return unauthorized error if expired api_token is passed' do
            @user.token_expires_at = 1.day.ago
            @user.save
            @user.reload

            post(api_preference_url, params: @preference_params, headers: { 'Email': @user.email, 'Api-Token': @user.api_token })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'raise bad request error if api_token is missing' do
            post(api_preference_url, params: @preference_params, headers: { 'Email': @user.email })

            assert_response(:bad_request)
          end

          should 'raise bad request error if email is missing' do
            post(api_preference_url, params: @preference_params, headers: { 'Api-Token': @user.api_token })

            assert_response(:bad_request)
          end
        end
      end

      context 'SEARCH' do
        context 'success' do
          should 'return parsed search results when search is successful' do
            stub_successful_search_request

            post(api_search_url, params: @search_params, headers: @headers)

            assert_response(:success)
            assert_includes(response.parsed_body.dig('data', 0), 'name')
            assert_includes(response.parsed_body.dig('data', 0), 'categories')
            assert_includes(response.parsed_body.dig('data', 0), 'rating')
            assert_includes(response.parsed_body.dig('data', 0), 'location')
            assert_includes(response.parsed_body.dig('data', 0), 'coordinates')
            assert_includes(response.parsed_body.dig('data', 0), 'distance')
            assert_includes(response.parsed_body.dig('data', 0), 'review_count')
            assert_includes(response.parsed_body.dig('data', 0), 'is_closed')
            assert_includes(response.parsed_body.dig('data', 0), 'price')
            assert_includes(response.parsed_body.dig('data', 0), 'url')
            assert_includes(response.parsed_body.dig('data', 0), 'image')
          end

          should 'return empty data array and message when search is successful but there is no search results' do
            params = @search_params
            params[:term] = 'blabla'
            stub_request_with_empty_business_data

            post(api_search_url, params: @search_params, headers: @headers)

            assert_response(:success)
            assert_equal(response.parsed_body['data'], [])
            assert_equal(response.parsed_body['message'], 'No restaurants found. Please try other search terms or location.')
          end
        end

        context 'error' do
          should 'return 422 status code and message error if external (Yelp) service call is not successful' do
            params = @search_params
            params[:address] = 'TMP 13'
            stub_request_with_unsupported_address

            post(api_search_url, params: params, headers: @headers)

            assert_response(:unprocessable_entity)
            assert_equal(response.parsed_body['message'], 'External Service Error or Location unsupported')
          end
        end

        context 'header errors' do
          should 'return not found error if wrong email header is passed' do
            post(api_search_url, params: @search_params, headers: { 'Email': '_________@isp.net', 'Api-Token': @user.api_token })

            assert_response(:not_found)
            assert_equal(response.parsed_body['message'], 'Resource not found')
          end

          should 'return unauthorized error if wrong api_token is passed' do
            post(api_search_url, params: @search_params, headers: { 'Email': @user.email, 'Api-Token': '123432341323asakdaosdk' })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'return unauthorized error if expired api_token is passed' do
            @user.token_expires_at = 1.day.ago
            @user.save
            @user.reload

            post(api_search_url, params: @search_params, headers: { 'Email': @user.email, 'Api-Token': @user.api_token })

            assert_response(:unauthorized)
            assert_equal(response.parsed_body['message'], 'Token expired, or wrong credentials')
          end

          should 'raise bad request error if api_token is missing' do
            post(api_search_url, params: @search_params, headers: { 'Email': @user.email })

            assert_response(:bad_request)
          end

          should 'raise bad request error if email is missing' do
            post(api_search_url, params: @search_params, headers: { 'Api-Token': @user.api_token })

            assert_response(:bad_request)
          end
        end
      end

      private

      def stub_successful_search_request
        stub_request(:get, 'https://api.yelp.com/v3/businesses/search?location=892%20ARLENE%20WAY,%20NOVATO,%20CA,%20USA&radius=8000&sort_by=distance&term=pizza')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                           'User-Agent' => 'Faraday v1.3.0' })
          .to_return(status: 200, body: File.read('test/factories/files/yelp_response.json'), headers: {})
      end

      def stub_request_with_empty_business_data
        body = { businesses: [],
                 total: 0,
                 region: { center: { longitude: -104.2108154296875, latitude: 30.758115118361516 } } }

        stub_request(:get, 'https://api.yelp.com/v3/businesses/search?location=892%20ARLENE%20WAY,%20NOVATO,%20CA,%20USA&radius=8000&sort_by=distance&term=blabla')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                           'User-Agent' => 'Faraday v1.3.0' })
          .to_return(status: 200, body: body.to_json, headers: {})
      end

      def stub_request_with_unsupported_address
        body = { error: { code: 'LOCATION_NOT_FOUND', description: 'Could not execute search, try specifying a more exact location.' } }

        stub_request(:get, 'https://api.yelp.com/v3/businesses/search?location=TMP%2013&radius=8000&sort_by=distance&term=pizza')
          .with(headers: { 'Accept' => '*/*',
                           'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                           'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                           'User-Agent' => 'Faraday v1.3.0' })
          .to_return(status: 400, body: body.to_json, headers: {})
      end
    end
  end
end
