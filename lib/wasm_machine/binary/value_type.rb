module WasmMachine::Binary
  # Representation of "Value Type"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#binary-valtype
  class ValueType
    # @param [Integer] byte
    # @return [WasmMachine::Binary::ValueType]
    def self.from(byte)
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
        raise WasmMachine::BinaryError, "Invalid value type: 0x#{byte.to_s(16).upcase}"
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

    # @param [Symbol] sym
    def initialize(sym)
      @sym = sym
    end

    # @return [Boolean]
    def ==(other)
      other.is_a?(self.class) && @sym == other.instance_variable_get(:@sym)
    end

    # @return [String]
    def to_s
      @sym.to_s
    end

    # @return [String]
    def inspect
      to_s
    end
  end
end
