require "rack/test"
require "rspec"
require "vcr"

ENV["RACK_ENV"] = "test"

require File.join(__dir__, "../lib/corbot")

module RSpecMixin
  include Rack::Test::Methods

  def app() Sinatra::Application end
end

VCR.configure do |config|
  config.cassette_library_dir = File.join(__dir__, "./cassettes")
  config.hook_into :webmock
end

RSpec.configure { |c| c.include RSpecMixin }
