# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require_relative '../config/environment'
require 'rails/test_help'
require 'database_cleaner'
require 'database_cleaner_support'

module ActiveSupport
  class TestCase
    include FactoryBot::Syntax::Methods

    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    DatabaseCleaner[:mongoid].strategy = :truncation
    DatabaseCleaner.clean_with :truncation
  end
end
