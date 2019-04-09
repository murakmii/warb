module WARB
  class FunctionType
    attr_reader :param_types, :return_type

    def self.from_io(io)
      raise WARB::BinaryError unless io.readbyte == 0x60

      param_types = io.read_vector { WARB::ValueType.from_byte(io.readbyte) }
      return_types = io.read_vector { WARB::ValueType.from_byte(io.readbyte) }

      new(param_types, return_types)
    end

    def initialize(param_types, return_types)
      raise WARB::BinaryError if return_types.size > 1

      @param_types = param_types
      @return_type = return_types.first
    end

    def inspect
      "#<#{self.class} " \
      "(#{@param_types.map(&:inspect).join(",")})=>" \
      "(#{@return_type})>" \
    end
  end
end
