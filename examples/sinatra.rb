require 'sinatra'
require_relative '../lib/yeller/rack'

Yeller::Rack.configure do |config|
  config.token = 'YOUR API KEY HERE'
end

use Yeller::Rack
get '/' do
  raise "error"
end
