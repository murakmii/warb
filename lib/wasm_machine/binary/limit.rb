module WasmMachine::Binary
  # Representation of "Limits"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#limits
  # @see https://webassembly.github.io/spec/core/valid/types.html#limits
  class Limit
    include WasmMachine::Binary::Assertion

    attr_reader :minimum, :maximum

    # @param [WasmMachine::Binary::Reader] reader
    # @param [Integer] range
    def initialize(reader, range:)
      max_flag = reader.read_byte
      assert(max_flag == 0 || max_flag == 1)

      @minimum = reader.read_u32
      assert(@minimum <= range)

      @maximum = (max_flag == 1) ? reader.read_u32 : nil
      assert(@maximum.nil? || (@maximum <= range && @maximum >= @minimum))
    end

    # @return [String]
    def inspect
      "#<Memory min:#{minimum} max:#{maximum || "NaN"}>"
    end

    # @return [Hash]
    def to_h
      { minimum: minimum, maximum: maximum }
    end
  end
end
