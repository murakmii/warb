module WasmMachine::Binary
  # Representation of "Function Type"
  #
  # @see https://webassembly.github.io/spec/core/binary/types.html#function-types
  class FunctionType
    MAGIC = 0x60

    attr_reader :parameters, :results

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      raise WasmMachine::BinaryError unless reader.read_byte == MAGIC

      @parameters = read_value_types(reader)
      @results = read_value_types(reader)
    end

    # @return [String]
    def inspect
      "#<FunctionType parameters:#{parameters} results:#{results}>"
    end

    # @return [Hash]
    def to_h
      { parameters: parameters, results: results }
    end

    private

      # @param [WasmMachine::Binary::Reader] reader
      # @return [Array<WasmMachine::Binary::ValueType>]
      def read_value_types(reader)
        reader.read(reader.read_u32).bytes.map do |b|
          WasmMachine::Binary::ValueType.from(b)
        end
      end
  end
end
