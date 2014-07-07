require_relative 'server'

module Yeller
  class Configuration
    attr_reader :token, :servers, :startup_params, :error_handler
    DEFAULT_SERVERS = [
      Yeller::SecureServer.new("collector1.yellerapp.com", 443),
      Yeller::SecureServer.new("collector2.yellerapp.com", 443),
      Yeller::SecureServer.new("collector3.yellerapp.com", 443),
      Yeller::SecureServer.new("collector4.yellerapp.com", 443),
      Yeller::SecureServer.new("collector5.yellerapp.com", 443),
    ]

    def initialize
      @servers = DEFAULT_SERVERS
      @startup_params = {}
      @error_handler = Yeller::LogErrorHandler.new
    end

    def remove_default_servers
      @servers = []
      self
    end

    def add_server(host, port=443)
      @servers << Yeller::SecureServer.new(host, port)
      self
    end

    def add_insecure_server(host, port=80)
      @servers << Yeller::Server.new(host, port)
    end

    def environment=(new_environment)
      @startup_params[:"application-environment"] = new_environment
    end

    def host=(new_host)
      @startup_params[:host] = new_host
    end

    def token=(token)
      @token = token
    end

    def error_handler=(new_error_handler)
      @error_handler = new_error_handler
    end
  end
end
