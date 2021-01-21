# frozen_string_literal: true

FactoryBot.define do
  factory :location do
    formatted_address { Faker::Address.full_address }
    street_name { Faker::Address.street_name }
    town { Faker::Address.city }
    state { Faker::Address.state }
    country { Faker::Address.country }
    postal_code { Faker::Address.postcode }
    latitude { Faker::Address.latitude }
    longitude { Faker::Address.longitude }
    location_type { 'seeded' }

    trait :acquired do
      transient do
        lat { nil }
        lon { nil }
      end

      formatted_address { nil }
      street_name { nil }
      town { nil }
      state { nil }
      country { nil }
      postal_code { nil }
      location_type { 'acquired' }
      latitude { lat }
      longitude { lon }
    end

    trait :with_users do
      transient do
        user { nil }
      end

      users { user }
    end
  end
end
