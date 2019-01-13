module WasmMachine::Binary::Section
  # Representation of "Global Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#global-section
  class GlobalSection
    # Representation of "Global"
    #
    # @see https://webassembly.github.io/spec/core/binary/modules.html#binary-global
    Global = Struct.new(:global_type, :expr) do
      # @return [String]
      def inspect
        "#<Global type:#{global_type} expr:#{expr.size}>"
      end

      # @return [Hash]
      def to_h
        { expr: expr }.merge(global_type.to_h)
      end
    end

    attr_reader :globals

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @globals = reader.read_vector do
        Global.new(
          WasmMachine::Binary::GlobalType.new(reader),
          reader.read_const_expr,
        )
      end
    end

    # @return [String]
    def inspect
      "#<GlobalSection globals:#{globals}>"
    end

    # @return [Hash]
    def to_h
      { globals: globals.map(&:to_h) }
    end
  end
end
