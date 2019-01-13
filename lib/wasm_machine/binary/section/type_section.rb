module WasmMachine::Binary::Section
  # Representation of "Type Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#type-section
  class TypeSection
    attr_reader :function_types

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @function_types = reader.read_vector do
        WasmMachine::Binary::FunctionType.new(reader)
      end
    end

    # @return [String]
    def inspect
      "#<TypeSection function_types:#{function_types}>"
    end

    # @return [Hash]
    def to_h
      { function_types: function_types.map(&:to_h) }
    end
  end
end
