require 'rack/request'
require_relative '../yeller'

module Yeller
  class Rack
    def self.configure(&block)
      @client = Yeller.client(&block)
    end

    def self.report(exception, options={})
      @client.report(exception, options)
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      begin
        @app.call(env)
      rescue Exception => exception
        Yeller::Rack.rescue_rack_exception(exception, env)
        raise exception
      end
    end

    def self.rescue_rack_exception(exception, env)
      request = ::Rack::Request.new(env)
      Yeller::Rack.report(
        exception,
        :url => request.url,
        :custom_data => {
          :params => request.params,
          :session => env.fetch('rack.session', {}),
      })
    end
  end
end
