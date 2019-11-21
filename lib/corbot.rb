require 'sinatra'
require "sinatra/reloader" if development?



get '/ping' do
  'pong'
end