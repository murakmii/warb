module WasmMachine::Binary::Section
  # Representation of "Memory Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#memory-section
  class MemorySection
    attr_reader :memories

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @memories = reader.read_vector do
        WasmMachine::Binary::MemoryType.new(reader)
      end
    end

    # @return [String]
    def inspect
      "#<MemorySection memories:#{memories.inspect}>"
    end

    # @return [Hash]
    def to_h
      { memories: memories.map(&:to_h) }
    end
  end
end
