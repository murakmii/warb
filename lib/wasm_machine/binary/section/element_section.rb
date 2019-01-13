module WasmMachine::Binary::Section
  # Representation of "Element Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#element-section
  class ElementSection
    Element = Struct.new(:table_index, :expr, :function_indexes) do
      # @return [String]
      def inspect
        "#<Data table:#{table_index} expr:#{expr.size} functions:#{function_indexes}>"
      end

      # @return [Hash]
      def to_h
        { table_index: table_index, expr: expr, function_indexes: function_indexes }
      end
    end

    attr_reader :elements

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @elements = reader.read_vector do
        Element.new(
          reader.read_u32,
          reader.read_const_expr,
          reader.read_vector { reader.read_u32 },
        )
      end
    end

    # @return [String]
    def inspect
      "#<ElementSection elements:#{elements}>"
    end

    # @return [Hash]
    def to_h
      { elements: elements.map(&:to_h) }
    end
  end
end
