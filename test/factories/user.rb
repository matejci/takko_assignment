# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    name  { Faker::FunnyName.name }
    password { Faker::String.random(length: 4) }
    password_confirmation { password }
    token_expires_at { Time.current + 1.hour }
    categories { {} }
  end
end
