module WasmMachine::Binary
  # Representation of "Table Types"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#table-types
  class TableType
    attr_reader :element, :limit

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @element = reader.read_byte

      if @element != 0x70
        raise WasmMachine::BinaryError, "Unsupport table element: 0x#{@element.to_s(16).upcase}"
      end

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
