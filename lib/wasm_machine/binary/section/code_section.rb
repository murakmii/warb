module WasmMachine::Binary::Section
  # Representation of "Code Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#code-section
  class CodeSection
    attr_reader :codes

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @codes = reader.read_vector { WasmMachine::Binary::Code.new(reader) }
    end

    # @return [String]
    def inspect
      "#<CodeSection codes:#{codes}>"
    end

    # @return [Hash]
    def to_h
      { codes: codes.map(&:to_h) }
    end
  end
end
