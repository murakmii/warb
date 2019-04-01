module WasmMachine
  class FunctionType
    def self.from_io(io)
      raise WasmMachine::BinaryError unless io.readbyte == 0x60

      param_types = io.read_vector { WasmMachine::ValueType.from_byte(io.readbyte) }
      return_types = io.read_vector { WasmMachine::ValueType.from_byte(io.readbyte) }

      new(param_types, return_types)
    end

    def initialize(param_types, return_types)
      @param_types = param_types
      @return_types = return_types
    end

    def inspect
      "#<#{self.class} " \
      "(#{@param_types.map(&:inspect).join(",")})=>" \
      "(#{@return_types.map(&:inspect).join(",")})>" \
    end
  end
end
