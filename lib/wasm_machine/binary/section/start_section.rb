module WasmMachine::Binary::Section
  # Representation of "Start Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#start-section
  class StartSection
    attr_reader :function_index

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @function_index = reader.read_u32
    end

    # @return [String]
    def inspect
      "#<StartSection function_index:#{function_index}>"
    end

    # @return [Hash]
    def to_h
      { function_index: function_index }
    end
  end
end
