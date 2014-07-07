module Yeller
  class ExceptionFormatter
    BACKTRACE_FORMAT = %r{^((?:[a-zA-Z]:)?[^:]+):(\d+)(?::in `([^']+)')?$}.freeze


    class IdentityBacktraceFilter
      def filter(trace)
        trace
      end
    end

    def self.format(exception, backtrace_filter=IdentityBacktraceFilter.new, options={})
      new(exception, backtrace_filter, options).to_hash
    end

    attr_reader :type, :options, :backtrace_filter

    def initialize(exception, backtrace_filter, options)
      @type = exception.class.name
      @message = exception.message
      @backtrace = exception.backtrace
      @options = options

      @backtrace_filter = backtrace_filter
    end

    def message
      # If a message is not given, rubby will set message to the class name
      @message == type ? nil : @message
    end

    def formatted_backtrace
      return [] unless @backtrace

      original_trace = @backtrace.map do |line|
        _, file, number, method = line.match(BACKTRACE_FORMAT).to_a
        [file, number, method]
      end
      backtrace_filter.filter(original_trace)
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
