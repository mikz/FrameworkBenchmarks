require "sinatra"
require "sinatra/json"
require "sinatra/activerecord"

require "em-synchrony"
require "em-synchrony/mysql2"
require "em-synchrony/activerecord"

set :logging, false
set :activerecord_logger, nil

if RUBY_PLATFORM == 'java'
  set :database, { :adapter => 'jdbc', :jndi => 'java:comp/env/jdbc/hello_world', :pool => 256 }
else
  set :database, { :adapter => 'em_mysql2', :database => 'hello_world', :username => 'root', :password => '', :host => 'localhost', :pool => 256, :timeout => 5000 }
end

class World < ActiveRecord::Base
  self.table_name = "World"
  attr_accessible :randomNumber
end

register Sinatra::Async

aget '/json' do
  body { json :message => 'Hello World!' }
end

aget '/db' do
  queries = (params[:queries] || 1).to_i
  sleep = params[:sleep].to_i

  Fiber.new {
    results = (1..queries).map do
      World.select("SLEEP(#{sleep})").first
      World.find(Random.rand(10000) + 1)
    end

    body results.to_json
  }.resume
end
