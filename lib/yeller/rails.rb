require 'rails'
require 'yeller'
require 'yeller/rack'

module Yeller
  class Rails
    def self.configure(&block)
      Yeller::Rack.configure do |config|
        config.error_handler = Yeller::LogErrorHandler.new(::Rails.logger)
        block.call(config)
      end
    end

    module ActionControllerCatchingHooks
      def self.included(base)
        base.send(:alias_method, :render_exception_without_yeller, :render_exception)
        base.send(:alias_method, :render_exception, :render_exception_with_yeller)
      end

      protected
      def render_exception_with_yeller(env, exception)
        Yeller::Rack.rescue_rack_exception(exception, env)
        render_exception_without_yeller(env, exception)
      end
    end

    class Railtie < ::Rails::Railtie
      initializer "yeller.use_rack_middleware" do |app|
        app.config.middleware.insert 0, "Yeller::Rack"
      end

      config.after_initialize do
        if defined?(::ActionDispatch::DebugExceptions)
          ::ActionDispatch::DebugExceptions.send(:include, Yeller::Rails::ActionControllerCatchingHooks)
        elsif defined(::ActionDispatch::ShowExceptions)
          ::ActionDispatch::ShowExceptions.send(:include, Yeller::Rails::ActionControllerCatchingHooks)
        end
      end
    end
  end
end
