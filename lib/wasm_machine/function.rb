module WasmMachine
  class Function
    attr_reader :type, :locals, :blocks, :instructions

    def initialize(type)
      @type = type
      @locals = []
      @instructions = nil
      @blocks = nil
    end

    def set_code_from_io(io)
      size = io.read_u32
      pos = io.pos

      io.read_vector do
        @locals.concat(
          Array.new(
            io.read_u32,
            WasmMachine::ValueType.from_byte(io.readbyte),
          )
        )
      end

      raise WasmMachine::BinaryError unless @type.param_types == @locals.slice(0, @type.param_types.size)

      @instructions = WasmMachine::BinaryIO.new(io.read(size - (io.pos - pos)))
      @blocks = WasmMachine::ControlFlow::Block.from_function_body(@type, @instructions).flatten_nested_blocks
      @instructions.rewind
    end

    def inspect
      "#<#{self.class} locals:#{@locals.size} instr:#{@instructions.size}>"
    end
  end
end
