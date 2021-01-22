# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'
require 'database_cleaner'
require 'database_cleaner_support'
require 'webmock/minitest'
require 'minitest/unit'
require 'mocha/minitest'

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    # parallelize(workers: :number_of_processors)

    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner.clean_with :truncation

    Shoulda::Matchers.configure do |config|
      config.integrate do |with|
        with.test_framework :minitest
        with.library :rails
      end
    end
  end
end
