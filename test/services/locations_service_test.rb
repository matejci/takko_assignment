# frozen_string_literal: true

require 'test_helper'

class LocationsServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  context '#call' do
    context 'success' do
      should 'add new location for a user if coordinates are not present, but some other non-coordinate field is present' do
        location = Location.new(location_type: 'acquired', latitude: nil, longitude: nil, postal_code: Faker::Address.postcode)

        before_service_call = Location.count
        LocationsService.new(user: @user, params: location.attributes.except('_id')).call
        after_service_call = Location.count

        assert_equal(before_service_call + 1, after_service_call)
      end

      should 'add new location if location attributes are not present but latitude and longitude are present' do
        location = Location.new(location_type: 'acquired', latitude: Faker::Address.latitude, longitude: Faker::Address.longitude)

        before_service_call = Location.count
        LocationsService.new(user: @user, params: location.attributes.except('_id')).call
        after_service_call = Location.count

        assert_equal(before_service_call + 1, after_service_call)
      end
    end

    context 'error' do
      should 'raise error if location type is wrong' do
        location = build(:location, location_type: 'whatever')

        assert_raises(Mongoid::Errors::Validations) do
          LocationsService.new(user: @user, params: location.attributes.except('_id')).call
        end
      end

      should 'raise error if location attributes are not present and latitude is present' do
        location = Location.new(location_type: 'acquired', latitude: Faker::Address.latitude)

        assert_raises(Mongoid::Errors::Validations) do
          LocationsService.new(user: @user, params: location.attributes).call
        end
      end

      should 'raise error if location attributes are not present and longitude is present' do
        location = Location.new(location_type: 'acquired', longitude: Faker::Address.longitude)

        assert_raises(Mongoid::Errors::Validations) do
          LocationsService.new(user: @user, params: location.attributes).call
        end
      end

      should 'log error if exception is raised' do
        location = Location.new(location_type: 'acquired', latitude: Faker::Address.latitude)

        error_message = "Error::LocationsService: \nmessage:\n  Validation of Location failed.\nsummary:\n  The following errors were found:"\
                        " Longitude can't be blank\nresolution:\n  Try persisting the document with valid data or remove the validations."

        Rails.logger.expects(:error).with(error_message)
        assert_raises(Mongoid::Errors::Validations) do
          LocationsService.new(user: @user, params: location.attributes).call
        end
      end
    end
  end
end
