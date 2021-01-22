# frozen_string_literal: true

require 'test_helper'

class LoginServiceTest < ActiveSupport::TestCase
  setup do
    @user = create(:user)
  end

  context '#call' do
    context 'success' do
      should 'log in user and return user record with new api_token' do
        params = { email: @user.email, password: @user.password }
        service = LoginService.new(params: params).call
        assert_not_equal(@user.api_token, service.dig(:data).api_token)
        assert_kind_of(User, service.dig(:data))
      end
    end

    context 'error' do
      should 'not log in user when password is wrong' do
        params = { email: @user.email, password: '' }
        api_token_before_login = @user.api_token
        LoginService.new(params: params).call
        api_token_after_login = @user.api_token

        assert_equal(api_token_before_login, api_token_after_login)
      end

      should 'return nil if login is unsuccessful' do
        params = { email: @user.email, password: '' }
        service = LoginService.new(params: params).call
        assert_nil(service)
      end

      should 'return nil if email does not exist' do
        assert_raises(Mongoid::Errors::DocumentNotFound) do
          LoginService.new(params: { email: 'whatever@isp.net' }).call
        end
      end

      should 'log error if exception is raised' do
        error_message = "Error::LoginService: \nmessage:\n  Document not found for class User with attributes {:email=>\"whatever@isp.net\"}"\
                        ".\nsummary:\n  When calling User.find_by with a hash of attributes, all attributes provided must match a document in"\
                        " the database or this error will be raised.\nresolution:\n  Search for attributes that are in the database or set the"\
                        ' Mongoid.raise_not_found_error configuration option to false, which will cause a nil to be returned instead of raising this error.'

        Rails.logger.expects(:error).with(error_message)
        assert_raises(Mongoid::Errors::DocumentNotFound) do
          LoginService.new(params: { email: 'whatever@isp.net' }).call
        end
      end
    end
  end
end
