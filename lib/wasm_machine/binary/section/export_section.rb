module WasmMachine::Binary::Section
  # Representation of "Export Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#export-section
  class ExportSection
    # Representation of "Export"
    #
    # @see https://webassembly.github.io/spec/core/binary/modules.html#binary-export
    class Export
      FUNCTION_INDEX = 0x00
      TABLE_INDEX = 0x01
      MEMORY_INDEX = 0x02
      GLOBAL_INDEX = 0x03

      attr_reader :name, :index_space, :index

      # @param [String] name
      # @param [Integer] index_space
      # @param [Integer] index
      def initialize(name, index_space, index)
        @name = name
        @index_space = index_space
        @index = index

        unless (FUNCTION_INDEX..GLOBAL_INDEX).include?(index_space)
          raise WasmMachine::BinaryError, "Invalid exported index space: 0x#{index_space.to_s(16).upcase}"
        end
      end

      # @return [String]
      def inspect
        "#<Export name:#{name} index:0x#{index_space.to_s(16).upcase}/#{index}>"
      end

      # @return [Hash]
      def to_h
        { name: name, index_space: index_space, index: index }
      end
    end

    attr_reader :exports

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @exports = reader.read_vector do
        Export.new(
          reader.read_utf8,
          reader.read_byte,
          reader.read_u32,
        )
      end
    end

    # @return [String]
    def inspect
      "#<ExportSection exports:#{exports.inspect}>"
    end

    # @return [Hash]
    def to_h
      { exports: exports.map(&:to_h) }
    end
  end
end
