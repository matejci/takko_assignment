# frozen_string_literal: true

require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  include DatabaseCleanerSupport

  test 'should not save location if it is not of proper type' do
    location = build(:location, location_type: 'location_type')
    assert_not(location.save)
  end

  test 'should not save location if type is empty' do
    location = build(:location, location_type: '')
    assert_not(location.save)
  end

  test 'should not save location if coordinates are blank and other address fields are empty' do
    location = build(:location, :acquired, lat: '', lon: '')
    assert_not(location.save)
  end

  test 'should save location if coordinates are blank, other address fields are empty, except postal_code' do
    location = build(:location, :acquired, lat: '', lon: '', postal_code: Faker::Address.postcode)
    assert(location.save)
  end

  test 'Location#full_address should return concatenated address if formatted_address is not available' do
    location = create(:location, formatted_address: nil)
    assert_equal(location.full_address, "#{location.street_name} #{location.town} #{location.state} #{location.country} #{location.postal_code}")
  end
end
