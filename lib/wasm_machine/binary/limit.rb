module WasmMachine::Binary
  # Representation of "Limits"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#limits
  class Limit
    attr_reader :minimum, :maximum

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      has_max = reader.read_byte == 1

      @minimum = reader.read_u32
      @maximum = has_max ? reader.read_u32 : nil
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

  # "Memory Types" has definition same as "Limits"
  class MemoryType < Limit; end
end
