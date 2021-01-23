# frozen_string_literal: true

require 'test_helper'

class YelpServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user, categories: { 'chinese' => 1, 'pizza' => 4, 'mexican' => 2 })
  end

  # call - context: success
  begin
    test "it will return 'businesses' objects sorted by distance" do
      stub_request_with_businesses_data
      service = YelpService.search(user: @user, search_params: { address: '892 ARLENE WAY, NOVATO, CA, USA', term: 'pizza', categories: 'chinese,pizza,mexican' })

      parsed_response = JSON.parse(service.body)
      restaurants = parsed_response['businesses']

      assert(restaurants.dig(0, 'distance') < restaurants.dig(1, 'distance'))
      assert(restaurants.dig(1, 'distance') < restaurants.dig(2, 'distance'))
      assert(restaurants.dig(3, 'distance') < restaurants.dig(4, 'distance'))
      assert(restaurants.dig(0, 'distance') < restaurants.dig(restaurants.size - 1, 'distance'))
    end

    test "if radius larger than 40 000 is passed, it will fallback to 40 000, it won't raise error" do
      stub_request_with_max_radius
      service = YelpService.search(user: @user, search_params: { address: '892 ARLENE WAY, NOVATO, CA, USA', term: 'pizza', categories: 'chinese,pizza,mexican', radius: 50_000 })

      assert(service.success?)
    end
  end

  # call - context: error
  begin
    test 'it will return error with code and description fields if address is not supported' do
      stub_location_not_found

      service = YelpService.search(user: @user, search_params: { address: 'TMP 13', term: 'coffee' })

      assert_includes(service.body, 'error')
      assert_includes(service.body, 'code')
      assert_includes(service.body, 'description')
    end

    test 'it will raise exception if user does not have saved location and address param is not passed' do
      assert_raises(StandardError) do
        YelpService.search(user: @user, search_params: { term: 'coffee' })
      end
    end

    test 'it will log error if exception is raised' do
      Rails.logger.expects(:error).with("Error::YelpService: undefined method `full_address' for nil:NilClass")
      assert_raises(StandardError) do
        YelpService.search(user: @user, search_params: { term: 'coffee' })
      end
    end
  end

  private

  def stub_request_with_businesses_data
    stub_request(:get, 'https://api.yelp.com/v3/businesses/search?categories=chinese,pizza,mexican&location=892%20ARLENE%20WAY,%20NOVATO,%20CA,%20USA&radius=8000&sort_by=distance&term=pizza')
      .with(headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                       'User-Agent' => 'Faraday v1.3.0' })
      .to_return(status: 200, body: File.read('test/factories/files/yelp_response.json'), headers: {})
  end

  def stub_request_with_max_radius
    stub_request(:get, 'https://api.yelp.com/v3/businesses/search?categories=chinese,pizza,mexican&location=892%20ARLENE%20WAY,%20NOVATO,%20CA,%20USA&radius=40000&sort_by=distance&term=pizza')
      .with(headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                       'User-Agent' => 'Faraday v1.3.0' })
      .to_return(status: 200, body: File.read('test/factories/files/yelp_response.json'), headers: {})
  end

  def stub_location_not_found
    body = { error: { code: 'LOCATION_NOT_FOUND', description: 'Could not execute search, try specifying a more exact location.' } }

    stub_request(:get, 'https://api.yelp.com/v3/businesses/search?location=TMP%2013&radius=8000&sort_by=distance&term=coffee')
      .with(headers: { 'Accept' => '*/*',
                       'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                       'Authorization' => 'Bearer iQMoEU6bt1J1D1eJSP8Q8bOLrqcrqoMrqwMfXsx_luLHlKWwphC-JKBcq2cOFjqMtEH7m3k541x87ZmHq_OkBjj2UbtniRIucxnHt-pndMi8bfETN903AiLj68v9X3Yx',
                       'User-Agent' => 'Faraday v1.3.0' })
      .to_return(status: 400, body: body.to_json, headers: {})
  end
end
