module WARB
  class Limit
    attr_reader :minimum, :maximum

    def self.from_io(io)
      has_max = io.read_flag
      new(io.read_u32, has_max ? io.read_u32 : nil)
    end

    def initialize(min, max)
      raise WARB::BinaryError if max && max < min

      @minimum = min
      @maximum = max
    end

    def in_range?(range)
      @minimum <= range && (@maximum.nil? || @maximum <= range)
    end

    def inspect
      "(#{@minimum}|#{@maximum ? @maximum : "inf"})"
    end
  end
end
