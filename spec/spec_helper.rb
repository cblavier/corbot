require "rack/test"
require "rspec"

ENV["RACK_ENV"] = "test"

Dir[File.join(__dir__, "../lib/**/*.rb")].each do |file|
  require file
end

module RSpecMixin
  include Rack::Test::Methods

  def app() Sinatra::Application end
end

RSpec.configure { |c| c.include RSpecMixin }
