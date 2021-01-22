# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  include DatabaseCleanerSupport
  setup do
    @user = create(:user)
  end

  test 'should not save user without email' do
    user = User.new
    assert_not(user.save)
  end

  test 'should not save user without name' do
    user = User.new
    assert_not(user.save)
  end

  # sometimes it might happen that this test fails, not sure why, maybe it's because DB doesn't reload model at time??
  test 'should not save user if email already exists' do
    email = @user.email
    user = build(:user, email: email)
    user.valid?
    assert_match(/Email is already taken/, user.errors.full_messages.to_sentence)
  end

  test 'should not save user if email is wrong format' do
    user = build(:user, email: 'adaasd')
    assert_not(user.save)
  end

  test 'should not create user if password length is less than 4 chars' do
    user = build(:user, password: '123', password_confirmation: '123')
    assert_not(user.save)
  end

  test 'should not create user if password length is more than 15 chars' do
    user = build(:user, password: '12345678910111213', password_confirmation: '12345678910111213')
    assert_not(user.save)
  end

  test 'should not create user if password does not match password_confirmation' do
    user = build(:user, password: '12345678910111214', password_confirmation: '12345678910111213')
    assert_not(user.save)
  end

  test 'should generate new api_token when created' do
    api_token = '123'
    user = create(:user, api_token: api_token)
    assert_not_equal(user.api_token, api_token)
  end
end
