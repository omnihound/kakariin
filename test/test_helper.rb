ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"

module ActiveSupport
  class TestCase
    # Parallel workers each get their own Postgres test database; on this
    # machine that setup deadlocks/OOMs with >1 worker, and the suite runs
    # in ~1.5s single-threaded anyway. Override with PARALLEL_WORKERS=N if
    # a faster CI environment can actually use it.
    parallelize(workers: ENV.fetch("PARALLEL_WORKERS", 1).to_i)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
