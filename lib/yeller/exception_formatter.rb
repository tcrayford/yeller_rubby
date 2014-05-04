module Yeller
  class ExceptionFormatter
    BACKTRACE_FORMAT = %r{^((?:[a-zA-Z]:)?[^:]+):(\d+)(?::in `([^']+)')?$}.freeze

    def self.format(exception, options={})
      new(exception, options).to_hash
    end

    attr_reader :type, :options

    def initialize(exception, options)
      @type = exception.class.name
      @message = exception.message
      @backtrace = exception.backtrace
      @options = options
    end

    def message
      # If a message is not given, rubby will set message to the class name
      @message == type ? nil : @message
    end

    def formatted_backtrace
      return [] unless @backtrace

      @backtrace.map do |line|
        _, file, number, method = line.match(BACKTRACE_FORMAT).to_a
        [file, number, method]
      end
    end

    def to_hash
      result = {
        message: message,
        stacktrace: formatted_backtrace,
        type: type,
        :"custom-data" => options.fetch(:custom_data, {})
      }
      result[:url] = options[:url] if options.key?(:url)
      result[:location] = options[:location] if options.key?(:location)
      result
    end
  end
end
