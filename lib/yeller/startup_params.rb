require_relative 'version'

module Yeller
  class StartupParams
    PRODUCTION = 'production'.freeze
    VERSION = "yeller_rubby: #{Yeller::VERSION}"

    def self.defaults(options={})
      {
        :host => Socket.gethostname,
        :"application-environment" => application_environment(options),
        :"client-version" => VERSION,
      }
    end

    def self.application_environment(options)
      options[:"application-environment"] ||
        ENV['RAILS_ENV'] ||
        ENV['RACK_ENV'] ||
        PRODUCTION
    end
  end
end
