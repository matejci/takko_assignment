# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  context 'INDEX' do
    should 'get index' do
      get root_url
      assert_response(:success)
    end
  end
end
