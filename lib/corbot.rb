require "sinatra"
Dir[File.join(__dir__, "**/*.rb")].each do |file|
  require file
end

if development?
  require "sinatra/reloader"
  also_reload "lib/**/*.rb"
end

include Security
include Record
include Interactive
include Refuge

set :slack_version_nb, "v0"
set :slack_signing_secret, ENV.fetch("SLACK_SIGNING_SECRET") { :missing_slack_signing_secret }
set :refuge_cookie, ENV.fetch("REFUGE_COOKIE") { :missing_refuge_cookie }
set :record_requests, false

before do
  request.body.rewind
  headers, body = request.env, request.body.read
  unless settings.test? || authenticate?(headers, body, settings)
    halt 403, "could not authenticate request"
  end
end

post "/" do
  record_request(request, "command") if settings.record_requests && settings.development?
  case params[:text].strip
  when "interactive"
    Thread.new do
      send_interactive_message(params[:response_url])
    end
  when "profile"
    get_refuge_profile(2075, settings.refuge_cookie).inspect
  when "ping"
    "pong"
  else
    params.inspect
  end
end

post "/interactive" do
  record_request(request, "interactive") if settings.record_requests && settings.development?
end

get "/ping" do
  "pong"
end
