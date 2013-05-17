require 'bundler/setup'
Bundler.require

require './hello_world'
run Sinatra::Application
