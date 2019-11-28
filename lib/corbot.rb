require "sinatra"
require "sinatra/activerecord"
Dir[File.join(__dir__, "**/*.rb")].each { |f| require f }

if development?
  require "sinatra/reloader"
  also_reload "lib/**/*.rb"
end

before do
  request.body.rewind
  headers, body = request.env, request.body.read
  unless settings.test? || Slack::Security.authenticate?(headers, body)
    halt 403, "could not authenticate request"
  end
end

post "/interactive" do
  if payload = params[:payload]
    json = JSON.parse(payload)
    if actions = json["actions"]
      actions.each { |action| Slack::Actions.perform(action) }
    else
      halt 400
    end
  else
    halt 400
  end
  status 200
end

get "/ping" do
  "pong"
end
