module WasmMachine::Binary::Section
  # Representation of "Data Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#data-section
  class DataSection
    Data = Struct.new(:memory_index, :expr, :bytes) do
      # @return [String]
      def inspect
        "#<Data mem:#{memory_index} expr:#{expr.size} bytes:#{bytes.size}>"
      end

      # @return [Hash]
      def to_h
        { memory_index: memory_index, expr: expr, bytes: bytes.bytes.to_a }
      end
    end

    attr_reader :data

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @data = reader.read_vector do
        Data.new(
          reader.read_u32,
          reader.read_const_expr,
          reader.read(reader.read_u32),
        )
      end
    end

    # @return [String]
    def inspect
      "#<DataSection data:#{data}>"
    end

    # @return [Hash]
    def to_h
      { data: data.map(&:to_h) }
    end
  end
end
