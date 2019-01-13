module WasmMachine::Binary::Section
  # Representation of "Table Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#table-section
  class TableSection
    attr_reader :tables

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @tables = reader.read_vector do
        WasmMachine::Binary::TableType.new(reader)
      end
    end

    # @return [String]
    def inspect
      "#<TableSection tables:#{tables.inspect}>"
    end

    # @return [Hash]
    def to_h
      { tables: tables.map(&:to_h) }
    end
  end
end
