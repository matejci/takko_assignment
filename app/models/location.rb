# frozen_string_literal: true

class Location
  include Mongoid::Document
  include Mongoid::Timestamps

  LOCATION_TYPES = %w[seeded acquired].freeze

  field :formatted_address, type: String
  field :street_name, type: String
  field :town, type: String
  field :county, type: String
  field :state, type: String
  field :country, type: String
  field :postal_code, type: String
  field :latitude, type: String
  field :longitude, type: String
  field :location_type, type: String

  # associations
  has_and_belongs_to_many :users, index: true

  # validations
  validates :location_type, inclusion: { in: LOCATION_TYPES, message: ' is not a valid location_type' }
  validates :latitude, :longitude, presence: true, if: :address_fields_empty?

  # callbacks

  # scopes
  scope :acquired, -> { where(location_type: 'acquired') }
  scope :default, -> { where(location_type: 'seeded') }

  def full_address
    formatted_address || attributes.slice('street_name', 'town', 'state', 'country', 'postal_code').values.reject(&:blank?).join(' ')
  end

  def address_fields_empty?
    postal_code.blank? && formatted_address.blank? && street_name.blank? && town.blank? && county.blank? && state.blank? && country.blank?
  end
end
