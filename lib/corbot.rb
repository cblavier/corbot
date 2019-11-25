require "sinatra"
require "sinatra/activerecord"
Dir[File.join(__dir__, "**/*.rb")].each { |f| require f }

if development?
  require "sinatra/reloader"
  also_reload "lib/**/*.rb"
end

set :slack_version_nb, "v0"
set :slack_signing_secret, ENV.fetch("SLACK_SIGNING_SECRET") { :missing_slack_signing_secret }
set :refuge_cookie, ENV.fetch("REFUGE_COOKIE") { :missing_refuge_cookie }
set :refuge_csrf, ENV.fetch("REFUGE_CSRF") { :missing_refuge_csrf }
set :refuge_city_id, ENV.fetch("REFUGE_CITY_ID") { :missing_refuge_city_id }
set :record_requests, false && settings.development?

before do
  request.body.rewind
  headers, body = request.env, request.body.read
  unless settings.test? || Slack::Security.authenticate?(headers, body, settings)
    halt 403, "could not authenticate request"
  end
  RecordRequests.record(request) if settings.record_requests
end

post "/" do
  case params[:text].strip
  when "interactive"
    Thread.new do
      Slack::Messages.send_interactive_message(params[:response_url])
    end
  when "profile"
    Refuge::Client.get_refuge_profile(2075, settings.refuge_cookie).inspect
  when "ping"
    "pong"
  else
    params.inspect
  end
end

post "/interactive" do
end

get "/ping" do
  "pong"
end
