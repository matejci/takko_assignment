# frozen_string_literal: true

class YelpService
  YELP_AUTH_HEADER = "Bearer #{ENV.fetch('YELP_API_KEY', '')}"
  RADIUS = 8_000 # in meters (5 miles)

  class << self
    def search(user:, search_params:)
      Faraday.get('https://api.yelp.com/v3/businesses/search', request_data(user, search_params), request_headers)
    rescue StandardError => e
      Rails.logger.error("Error::YelpService: #{e.message}")
      raise e
    end

    private

    def request_data(user, search_params)
      req_params = {
        radius: radius(search_params),
        sort_by: 'distance'
      }
      req_params.merge!(prepare_location(user, search_params))
      req_params.merge!(term: search_params[:term]) if search_params[:term].present?
      req_params.merge!(categories: search_params[:categories]) if search_params[:categories].present?
      req_params
    end

    def prepare_location(user, params)
      if params[:address].present? || params[:postal_code].present?
        { location: params.except(:term).values.reject(&:blank?).join(', ') }
      elsif user.locations.acquired.any?
        location = user.locations.acquired.last
        { latitude: location.latitude, longitude: location.longitude }
      else
        { location: user.locations.default.full_address }
      end
    end

    def request_headers
      { 'Authorization': YELP_AUTH_HEADER }
    end

    def radius(search_params)
      radius = search_params[:radius].presence || RADIUS
      radius.to_i > 40_000 ? 40_000 : radius.to_i
    end
  end
end

# term - string - Optional.
#    Search term, for example "food" or "restaurants". The term may also be business names, such as "Starbucks".
#    If term is not included the endpoint will default to searching across businesses from a small number of popular categories.

# location - string - Required if either latitude or longitude is not provided.
#    This string indicates the geographic area to be used when searching for businesses.
#    Examples: "New York City", "NYC", "350 5th Ave, New York, NY 10118". Businesses returned in the response may not be strictly within the specified location.

# latitude - decimal - Required if location is not provided. Latitude of the location you want to search nearby.
# longitude - decimal - Required if location is not provided. Longitude of the location you want to search nearby.

# radius - int - Optional. A suggested search radius in meters. This field is used as a suggestion to the search.
#    The actual search radius may be lower than the suggested radius in dense urban areas, and higher in regions of less business density.
#    If the specified value is too large, a AREA_TOO_LARGE error may be returned. The max value is 40000 meters (about 25 miles).

# categories - string - Optional.
#     Categories to filter the search results with. See the list of supported categories.
#     The category filter can be a list of comma delimited categories. For example, "bars,french" will filter by Bars OR French.
#     The category identifier should be used (for example "discgolf", not "Disc Golf").

# locale  string  Optional. Specify the locale into which to localize the business information. See the list of supported locales. Defaults to en_US.
# limit int Optional. Number of business results to return. By default, it will return 20. Maximum is 50.
# offset  int Optional. Offset the list of returned business results by this amount.

# sort_by - string - Optional.
#     Suggestion to the search algorithm that the results be sorted by one of the these modes: best_match, rating, review_count or distance.
#     The default is best_match. Note that specifying the sort_by is a suggestion (not strictly enforced) to Yelp's search, which considers multiple input parameters
#     to return the most relevant results. For example, the rating sort is not strictly sorted by the rating value, but by an adjusted rating value that takes into account
#     the number of ratings, similar to a Bayesian average. This is to prevent skewing results to businesses with a single review.
