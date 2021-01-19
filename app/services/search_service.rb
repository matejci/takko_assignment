# frozen_string_literal: true

class SearchService
  class LocationNotSupported < StandardError; end

  Restaurant = Struct.new(:external_id, :name, :categories, :rating, :location, :coordinates, :distance, :review_count, :is_closed, :price, :url, :image)

  def initialize(user:, params:)
    @user = user
    @params = params
  end

  def call
    search
  rescue StandardError => e
    Rails.logger.error("Error::SearchService: #{e.message}")
    raise e
  end

  private

  attr_reader :user, :params

  def search
    yelp_results = YelpService.search(user: user, search_params: params)

    raise LocationNotSupported unless yelp_results.status.to_s.starts_with?('2')

    parse_yelp_results(yelp_results.body)
  end

  def parse_yelp_results(yelp_results)
    businesses = JSON.parse(yelp_results)&.dig('businesses')

    return { data: [], message: 'No restaurants found. Please try other search terms or location' } if businesses.blank?

    businesses.each_with_object([]) do |business, restaurants|
      restaurant = Restaurant.new.tap do |r|
        r.external_id = business.dig('id')
        r.name = business.dig('name')
        r.categories = business.dig('categories')&.map { |cat| cat['alias'] }
        r.rating = business.dig('rating')
        r.location = business.dig('location', 'display_address')
        r.coordinates = business.dig('coordinates')
        r.distance = business.dig('distance').round(2)
        r.review_count = business.dig('review_count')
        r.is_closed = business.dig('is_closed') ? 'Yes' : 'No'
        r.price = business.dig('price')
        r.url = business.dig('url')
        r.image = business.dig('image_url')
      end

      restaurants << restaurant
    end
  end
end
