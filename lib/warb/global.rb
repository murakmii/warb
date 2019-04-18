module WARB
  class Global
    attr_reader :value_class, :value

    def self.from_io(mod, io)
      global = new(WARB::Value::ClassDetector.from_byte(io.readbyte), io.read_flag)
      global.set(WARB::ConstantExpr.evaluate(mod, io))
      global
    end

    def initialize(value_class, mutable)
      @value_class = value_class
      @mutable = mutable
      @value = nil
    end

    def mutable?
      @mutable
    end

    def set(value)
      raise WARB::BinaryError unless value.class == @value_class
      @value = value
    end
  end
end
