module WasmMachine
  class Global
    attr_reader :value_type, :value

    def self.from_io(io)
      new(
        WasmMachine::ValueType.from_byte(io.readbyte),
        io.read_flag,
        WasmMachine::ConstantExpr.evaluate(io)
      )
    end

    def initialize(value_type, mutable, value)
      @value_type = value_type
      @mutable = mutable
      @value =value
    end

    def mutable?
      @mutable
    end
  end
end
