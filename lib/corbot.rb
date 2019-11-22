require 'sinatra'
require "sinatra/reloader" if development?

get '/ping' do
  'pong'
end

post '/' do
  case params[:text].trim
  when "help"
    "coucou"
  when "ping"
    "pong"
  else
    params.inspect
  end
end