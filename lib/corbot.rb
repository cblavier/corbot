require "sinatra"
require "sinatra/reloader" if development?

Dir[File.join(__dir__, "**/*.rb")].each do |file|
  require file
end

include Security

set :slack_version_nb, "v0"
set :slack_signing_secret, ENV.fetch("SLACK_SIGNING_SECRET") { ":missing_slack_signing_secret" }
set :record, false

before do
  request.body.rewind
  headers, body = request.env, request.body.read
  unless settings.test? || authenticate?(headers, body, settings)
    halt 403, "could not authenticate request"
  end
end

get "/ping" do
  "pong"
end

post "/" do
  record_request(request) if settings.record && settings.development?
  case params[:text].strip
  when "help"
    "coucou"
  when "ping"
    "pong"
  else
    params.inspect
  end
end
