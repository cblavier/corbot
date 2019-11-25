ENV["RACK_ENV"] = "test"
require "sinatra/activerecord"
require "rspec"
require "rack/test"
require "vcr"
require "database_cleaner"
require "rake"
require File.join(__dir__, "../lib/corbot")

module RSpecMixin
  include Rack::Test::Methods

  def app() Sinatra::Application end
end

load "sinatra/activerecord/rake.rb"
Rake::Task["db:prepare"].invoke

VCR.configure do |config|
  config.cassette_library_dir = File.join(__dir__, "./cassettes")
  config.hook_into :webmock
  config.filter_sensitive_data("<<<REFUGE_COOKIE>>>") { ENV["REFUGE_COOKIE"] }
  config.filter_sensitive_data("<<<REFUGE_CSRF>>>") { ENV["REFUGE_CSRF"] }
end

RSpec.configure do |config|
  config.include RSpecMixin

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
