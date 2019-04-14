module WARB
  class Global
    attr_reader :value_type, :value

    def self.from_io(io)
      new(
        WARB::Value::ClassDetector.from_byte(io.readbyte),
        io.read_flag,
        WARB::ConstantExpr.evaluate(io)
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
