# frozen_string_literal: true

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include ActiveModel::SecurePassword

  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze

  field :email, type: String
  field :name, type: String
  field :password_digest, type: String
  field :api_token, type: String
  field :token_expires_at, type: String

  has_secure_password

  # associations
  has_and_belongs_to_many :locations

  # validations
  validates :email, :name, presence: true
  validates :email, format: EMAIL_REGEX, uniqueness: true
  validates :password, presence: true, length: { minimum: 4, maximum: 15 }, if: :validate_password?
  validates :api_token, uniqueness: true, allow_nil: true

  # callbacks
  before_create :generate_api_token

  # scopes

  def generate_new_token
    generate_api_token
  end

  private


  def generate_api_token
    self.token_expires_at = 1.hour.from_now
    self.api_token = loop do
      token = SecureRandom.urlsafe_base64
      break token unless User.where(api_token: token).exists?
    end
  end

  def validate_password?
    new_record? || password.present?
  end
end
