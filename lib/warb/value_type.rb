module WARB
  class ValueType
    attr_reader :sym, :bits

    def self.from_byte(byte)
      MAP[byte - 0x7C] || raise(WARB::BinaryError)
    end

    def self.i32
      @i32 ||= new(:i32, 32, 0)
    end

    def self.i64
      @i64 ||= new(:i64, 64, 0)
    end

    def self.f32
      @f32 ||= new(:f32, 32, 0.0)
    end

    def self.f64
      @f64 ||= new(:f64, 64, 0.0)
    end

    def initialize(sym, bits, zero_value)
      @sym = sym
      @bits = bits
      @zero_value = zero_value
    end

    MAP = [f64, f32, i64, i32].freeze

    def ==(t)
      t.is_a?(self.class) && sym == t.sym
    end

    def inspect
      sym.to_s
    end

    def alloc
      WARB::Value.new(self, @zero_value)
    end
  end
end
