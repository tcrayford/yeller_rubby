require 'sinatra'
require 'thin'

class FakeYellerApi
  HOST = "localhost"
  attr_reader :token

  def self.start(token, *ports, &block)
    apis  = ports.map { new(token) }
    mutex = Mutex.new
    ready = ConditionVariable.new

    Thin::Logging.silent = true

    t = Thread.new {
      # Run Thin inside an EventMachine loop so starting it is non-blocking
      EM.run {
        mutex.synchronize {
          ports.zip(apis).each do |port, api|
            app = FakeYellerApi::App.new(api)
            Thin::Server.start(app, HOST, port)
          end
          ready.signal
        }
      }
    }

    # Wait until the server is up and running, then execute the block
    mutex.synchronize {
      ready.wait(mutex)
      begin
        block.call(*apis)
      rescue Exception => e
        raise e
      ensure
        t.terminate
      end
    }
  end

  def initialize(token)
    @token = token
  end

  def receive!(params)
    @received_params = params
  end

  def receive_deploy!(params)
    @deploy_params = params
  end

  def has_received_exception?(e)
    @received_params && e.class.name == @received_params.fetch('type')
  end

  def has_received_deploy?(revision)
    @deploy_params && @deploy_params[:revision] == revision
  end

  class App < Sinatra::Base
    def initialize(api)
      @api = api
      super
    end

    post '/:api_token/?' do
      if params[:api_token] == @api.token
        exception = JSON.load(request.body.read)
        @api.receive!(exception)
      end
    end

    post '/:api_token/deploys/?' do
      if params[:api_token] == @api.token
        @api.receive_deploy!(params)
      end
    end
  end
end
