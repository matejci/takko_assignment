# frozen_string_literal: true

require 'test_helper'

class UpdatePreferenceServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  context '#call' do
    context 'success' do
      should "increase count for category if vote is 'false'" do
        user = create(:user, categories: { 'pizza' => 1 })
        vote_count_before_service_call = user.categories['pizza']
        UpdatePreferenceService.new(user: user, params: { categories: 'pizza', vote: 'true' }).call
        vote_count_after_service_call = User.find(user.id).categories['pizza']
        assert_equal(vote_count_after_service_call, vote_count_before_service_call + 1)
      end

      should "increase count for multiple categories if vote is 'false'" do
        user = create(:user, categories: { 'pizza' => 1, 'coffee' => 3 })
        pizza_count_before_service_call = user.categories['pizza']
        coffee_count_before_service_call = user.categories['coffee']

        UpdatePreferenceService.new(user: user, params: { categories: 'pizza, coffee', vote: 'true' }).call

        pizza_count_after_service_call = User.find(user.id).categories['pizza']
        coffee_count_after_service_call = User.find(user.id).categories['coffee']

        assert_equal(pizza_count_after_service_call, pizza_count_before_service_call + 1)
        assert_equal(coffee_count_after_service_call, coffee_count_before_service_call + 1)
      end

      should "decrease count for category if vote is 'true'" do
        user = create(:user, categories: { 'pizza' => 1 })
        vote_count_before_service_call = user.categories['pizza']
        UpdatePreferenceService.new(user: user, params: { categories: 'pizza', vote: 'false' }).call
        vote_count_after_service_call = User.find(user.id).categories['pizza']
        assert_equal(vote_count_after_service_call, vote_count_before_service_call - 1)
      end

      should "decrease count for multiple categories if vote is 'true'" do
        user = create(:user, categories: { 'pizza' => 1, 'coffee' => 3 })
        pizza_count_before_service_call = user.categories['pizza']
        coffee_count_before_service_call = user.categories['coffee']

        UpdatePreferenceService.new(user: user, params: { categories: 'pizza, coffee', vote: 'false' }).call

        pizza_count_after_service_call = User.find(user.id).categories['pizza']
        coffee_count_after_service_call = User.find(user.id).categories['coffee']

        assert_equal(pizza_count_after_service_call, pizza_count_before_service_call - 1)
        assert_equal(coffee_count_after_service_call, coffee_count_before_service_call - 1)
      end
    end

    context 'error' do
      should "return nil if value of vote param is different then 'false' or 'true' and won't update categories preference" do
        user_categories_before_service_call = @user.categories
        service = UpdatePreferenceService.new(user: @user, params: { categories: 'mexican,italian', vote: 'yes' }).call
        assert_nil(service)
        assert_equal(user_categories_before_service_call, @user.categories)
      end

      should "return nil if value of categories param is blank and won't update categories preference" do
        user_categories_before_service_call = @user.categories
        service = UpdatePreferenceService.new(user: @user, params: { categories: '', vote: 'true' }).call
        assert_nil(service)
        assert_equal(user_categories_before_service_call, @user.categories)
      end

      should "raise error if user's preference cannot be saved" do
        user = build(:user, name: '')
        assert_raises(Mongoid::Errors::Validations) do
          UpdatePreferenceService.new(user: user, params: { categories: 'pizza', vote: 'true' }).call
        end
      end

      should 'log error if exception is raised' do
        user = build(:user, name: '')
        error_message = "Error::UpdatePreferenceService: \nmessage:\n  Validation of User failed.\nsummary:\n  The following errors were found:"\
                        " Name can't be blank\nresolution:\n  Try persisting the document with valid data or remove the validations."

        Rails.logger.expects(:error).with(error_message)
        assert_raises(Mongoid::Errors::Validations) do
          UpdatePreferenceService.new(user: user, params: { categories: 'pizza', vote: 'true' }).call
        end
      end
    end
  end
end
