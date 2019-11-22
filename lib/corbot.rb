require "sinatra"
require "sinatra/reloader" if development?

also_reload "lib/**/*.rb"
Dir[File.join(__dir__, "**/*.rb")].each do |file|
  require file
end

include Security
include Record
include Interactive

set :slack_version_nb, "v0"
set :slack_signing_secret, ENV.fetch("SLACK_SIGNING_SECRET") { ":missing_slack_signing_secret" }
set :record, true

before do
  request.body.rewind
  headers, body = request.env, request.body.read
  unless settings.test? || authenticate?(headers, body, settings)
    halt 403, "could not authenticate request"
  end
end

post "/" do
  record_request(request, "command") if settings.record && settings.development?
  case params[:text].strip
  when "interactive"
    Thread.new do
      send_interactive_message(params[:response_url])
    end
  when "ping"
    "pong"
  else
    params.inspect
  end
end

post "/interactive" do
  record_request(request, "interactive") if settings.record && settings.development?
end

get "/ping" do
  "pong"
end
