module WasmMachine::Binary
  # Representation of "Code"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#binary-code
  class Code
    Local = Struct.new(:count, :value_type) do
      def inspect
        "#<Local value_type:#{value_type} count:#{count}>"
      end

      # @return [Hash]
      def to_h
        { count: count, value_type: value_type }
      end
    end

    attr_reader :locals, :expr

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      reader = reader.new_reader_for(reader.read_u32)

      @locals = reader.read_vector do
        Local.new(
          reader.read_u32,
          WasmMachine::Binary::ValueType.from(reader.read_byte)
        )
      end

      @expr = reader.read_until_eof.bytes.to_a
    end

    # @return [String]
    def inspect
      "#<Code locals:#{locals} expr:#{expr.size}>"
    end

    # @return [Hash]
    def to_h
      { locals: locals.map(&:to_h), expr: expr }
    end
  end
end
