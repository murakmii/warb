module WasmMachine
  class ValueType
    attr_reader :sym

    def self.from_byte(byte)
      case byte
      when 0x7F
        i32
      when 0x7E
        i64
      when 0x7D
        f32
      when 0x7C
        f64
      else
        raise WasmMachine::BinaryError
      end
    end

    def self.i32
      @i32 ||= new(:i32)
    end

    def self.i64
      @i64 ||= new(:i64)
    end

    def self.f32
      @f32 ||= new(:f32)
    end

    def self.f64
      @f64 ||= new(:f64)
    end

    def initialize(sym)
      @sym = sym
    end

    def ==(t)
      t.is_a?(self.class) && sym == t.sym
    end

    def inspect
      sym.to_s
    end
  end
end
