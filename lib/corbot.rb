require 'sinatra'
require 'sinatra/activerecord'
require 'pp'
Dir[File.join(__dir__, '**/*.rb')].each { |f| require f }

if development?
  require 'sinatra/reloader'
  also_reload 'lib/**/*.rb'
end

before do
  request.body.rewind
  headers = request.env
  body = request.body.read
  unless settings.test? || Slack::Security.authenticate?(headers, body)
    halt 403, 'could not authenticate request'
  end
end

post '/interactive' do
  if (payload = params[:payload])
    json = JSON.parse(payload)
    if (actions = json['actions'])
      actions.each { |action| Slack::Actions.perform_action(action) }
    elsif (json['type'] == 'message_action') && (action = json['callback_id'])
      Slack::Actions.perform_message_action(
        action,
        trigger_id: json['trigger_id'],
        message: json['message']
      )
    else
      halt 400
    end
  else
    halt 400
  end
  status 200
end

get '/ping' do
  'pong'
end
