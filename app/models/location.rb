# frozen_string_literal: true

class Location
  include Mongoid::Document
  include Mongoid::Timestamps

  field :formatted_address, type: String
  field :street_name, type: String
  field :town, type: String
  field :county, type: String
  field :state, type: String
  field :country, type: String
  field :postal_code, type: String
  field :latitude, type: String
  field :longitude, type: String

  # associations
  has_and_belongs_to_many :users

  # validations

  # callbacks

  # scopes
end
