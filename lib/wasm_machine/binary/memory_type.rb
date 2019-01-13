module WasmMachine::Binary
  # Representation of "Memory Types"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#memory-types
  # @see https://webassembly.github.io/spec/core/valid/types.html#memory-types
  class MemoryType < Limit
    RANGE = 2**16

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      super(reader, range: RANGE)
    end
  end
end
