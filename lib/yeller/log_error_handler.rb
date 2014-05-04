require 'logger'
module Yeller
  class LogErrorHandler
    def initialize(logger=Logger.new(STDERR))
      @logger = logger
    end

    def handle(e)
      @logger.warn(e)
    end
  end
end
