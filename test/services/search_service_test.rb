# frozen_string_literal: true

require 'test_helper'

class SearchServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
    @seeded_location = create(:location)
    @user.locations << @seeded_location
    @user.save!
    @address = '892 ARLENE WAY, NOVATO, CA, USA'
  end

  # call - context: success
  begin
    test 'return hash of data and message keys if call is successfull' do
      stub_request_with_businesses_data
      service = SearchService.new(user: @user, params: { term: 'coffee', address: @address }).call

      assert_includes(service, :data)
      assert_includes(service, :message)
    end

    test 'return data array if call is successfull' do
      stub_request_with_businesses_data
      service = SearchService.new(user: @user, params: { term: 'coffee', address: @address }).call

      assert_kind_of(Array, service.dig(:data))
    end

    test 'return message if data array is empty' do
      stub_request_with_empty_business_data

      service = SearchService.new(user: @user, params: { term: 'coffee', address: 'Jeff Davis County, Texas, United States of America' }).call

      assert_empty(service[:data])
      assert_match(/No restaurants found. Please try other search terms or location./, service[:message])
    end

    test "return array of 'Restaurants' if data is present" do
      stub_request_with_businesses_data
      service = SearchService.new(user: @user, params: { term: 'coffee', address: @address }).call

      assert_kind_of(SearchService::Restaurant, service[:data].first)
    end

    test 'return nil message if data is present' do
      stub_request_with_businesses_data
      service = SearchService.new(user: @user, params: { term: 'coffee', address: @address }).call

      assert_nil(service[:message])
    end
  end

  # call - context: error
  begin
    test 'raise exception if location is not supported' do
      stub_request_with_unsupported_address

      assert_raises(SearchService::ExternalServiceError) do
        SearchService.new(user: @user, params: { term: 'coffee', address: 'TMP 13' }).call
      end
    end

    test 'log error if exception is raised' do
      stub_request_with_unsupported_address

      error_message = 'Error::SearchService: SearchService::ExternalServiceError'

      Rails.logger.expects(:error).with(error_message)
      assert_raises(SearchService::ExternalServiceError) do
        SearchService.new(user: @user, params: { term: 'coffee', address: 'TMP 13' }).call
      end
    end
  end

  private

  def stub_request_with_businesses_data
    body = { businesses: [{ id: 'v5BsLtHgAPNcVzpr71ymCg',
                            alias: 'peets-coffee-novato-2',
                            name: "Peet's Coffee",
                            image_url: 'https://s3-media2.fl.yelpcdn.com/bphoto/_Qgzh_50T1s1ONL9jkDtlQ/o.jpg',
                            is_closed: false,
                            url: 'https://www.yelp.com/biz/peets-coffee-novato-2?adjust_creative=g6GHAiWKHC12LNduHCT5KQ&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=g6GHAiWKHC12LNduHCT5KQ',
                            review_count: 53,
                            categories: [{ alias: 'coffee', title: 'Coffee & Tea' }],
                            rating: 3.5,
                            coordinates: { latitude: 38.10622, longitude: -122.57008 },
                            transactions: ['delivery'],
                            price: '$',
                            location: { address1: '7320 Redwood Blvd',
                                        address2: '',
                                        address3: '',
                                        city: 'Novato',
                                        zip_code: '94945',
                                        country: 'US',
                                        state: 'CA',
                                        display_address: ['7320 Redwood Blvd', 'Novato, CA 94945']},
                            phone: '+14158974920',
                            display_phone: '(415) 897-4920',
                            distance: 3778.1206557309465 }],
             total: 1,
             region: { center: { longitude: -122.55008697509766, latitude: 38.07619234107205 } } }

    stub_request(:get, 'https://api.yelp.com/v3/businesses/search?location=892%20ARLENE%20WAY,%20NOVATO,%20CA,%20USA&radius=8000&sort_by=distance&term=coffee')
      .with(headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                       'User-Agent' => 'Faraday v1.3.0' })
      .to_return(status: 200, body: body.to_json, headers: {})
  end

  def stub_request_with_empty_business_data
    body = { businesses: [],
             total: 0,
             region: { center: { longitude: -104.2108154296875, latitude: 30.758115118361516 } } }

    stub_request(:get, 'https://api.yelp.com/v3/businesses/search?location=Jeff%20Davis%20County,%20Texas,%20United%20States%20of%20America&radius=8000&sort_by=distance&term=coffee')
      .with(headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                       'User-Agent' => 'Faraday v1.3.0' })
      .to_return(status: 200, body: body.to_json, headers: {})
  end

  def stub_request_with_unsupported_address
    body = { error: { code: 'LOCATION_NOT_FOUND', description: 'Could not execute search, try specifying a more exact location.' } }

    stub_request(:get, 'https://api.yelp.com/v3/businesses/search?location=TMP%2013&radius=8000&sort_by=distance&term=coffee')
      .with(headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                       'User-Agent' => 'Faraday v1.3.0' })
      .to_return(status: 400, body: body.to_json, headers: {})
  end
end
