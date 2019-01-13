module WasmMachine::Binary
  # Representation of "Global Type"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#global-types
  class GlobalType
    include WasmMachine::Binary::Assertion

    attr_reader :value_type

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @value_type = WasmMachine::Binary::ValueType.from(reader.read_byte)
      @mutable = reader.read_byte

      assert(@mutable == 0 || @mutable == 1)
    end

    # @return [Boolean]
    def mutable?
      @mutable == 1
    end

    # @return [String]
    def to_s
      "#<GlobalType mutable:#{mutable?} type:#{value_type}>"
    end

    # @return [String]
    def inspect
      to_s
    end

    # @return [Hash]
    def to_h
      { mutable: mutable?, value_type: value_type }
    end
  end
end
