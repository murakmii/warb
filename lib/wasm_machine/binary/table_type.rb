module WasmMachine::Binary
  # Representation of "Table Types"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#table-types
  # @see https://webassembly.github.io/spec/core/valid/types.html#table-types
  class TableType
    include WasmMachine::Binary::Assertion

    attr_reader :element, :limit

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @element = reader.read_byte

      assert(@element == 0x70, "Unsupport table element: 0x#{@element.to_s(16).upcase}")

      @limit = WasmMachine::Binary::Limit.new(reader, range: 2**32)
    end

    # @return [String]
    def inspect
      "#<TableType element:#{element} limit:#{limit}>"
    end

    # @return [Hash]
    def to_h
      { element: element, limit: limit.to_h }
    end
  end
end
