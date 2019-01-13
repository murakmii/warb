module WasmMachine::Binary::Section
  # Representation of "Function Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#function-section
  class FunctionSection
    attr_reader :type_indexes

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @type_indexes = reader.read_vector { reader.read_u32 }
    end

    # @return [String]
    def inspect
      "#<FunctionSection type_indexes:#{type_indexes}>"
    end

    # @return [Hash]
    def to_h
      { type_indexes: type_indexes }
    end
  end
end
