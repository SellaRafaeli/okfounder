puts "starting app..."

require 'bundler'
require 'active_support/core_ext'
require 'sinatra/reloader' #dev-only
require 'json'
require 'open-uri'

puts "requiring gems..."
Bundler.require

require './setup'
require './my_lib'

require_all './db'
require_all './mw'
require_all './bl'

include Helpers

get '/ping' do
  {msg: '123 pong from SNM', pong: true}
end

get '/error' do
  a= b
end

get '/' do
  erb :index, layout: :layout
end