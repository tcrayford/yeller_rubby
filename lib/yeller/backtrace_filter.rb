module Yeller
  class BacktraceFilter
    attr_reader :filters
    def initialize(filters)
      @filters = filters
    end

    def filter(trace)
      trace.map do |frame|
        [filter_filename(frame[0]), frame[1], frame[2]]
      end
    end

    def filter_filename(filename)
      filters.each do |filter|
        filename.gsub!(filter[0], filter[1])
      end
      filename
    end
  end
end
