module WARB
  class Table
    def self.from_io(io)
      elem_type =
        case io.readbyte
        when 0x70
          :funcref
        else
          raise WARB::BinaryError
        end

      new(elem_type, WARB::Limit.from_io(io))
    end

    def initialize(elem_type, limit)
      raise WARB::BinaryError unless limit.in_range?(2**32)

      @elem_type = elem_type
      @elements = Array.new(limit.maximum || limit.minimum)
    end

    def []=(index, element)
      raise WARB::BinaryError if index < 0 || index >= @elements.size

      case @elem_type
      when :funcref
        raise WARB::BinaryError unless element.is_a?(WARB::Function)
      end

      @elements[index] = element
    end
  end
end
