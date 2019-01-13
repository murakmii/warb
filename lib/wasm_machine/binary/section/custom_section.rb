module WasmMachine::Binary::Section
  # Representation of "Custom Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#custom-section
  class CustomSection
    attr_reader :name, :bytes

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @name = reader.read_utf8
      @bytes = reader.read_until_eof
    end

    # @return [Hash]
    def to_h
      { custom_name: name, bytes: bytes.bytes.to_a }
    end
  end
end
