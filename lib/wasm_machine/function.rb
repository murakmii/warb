module WasmMachine
  class Function
    def initialize(type)
      @type = type
      @locals = []
      @block = nil
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

      @block = WasmMachine::ControlFlow::Block.from_function_body(@type, io.read(size - (io.pos - pos)))
    end

    def inspect
      "#<#{self.class} locals:#{@locals.size}>"
    end
  end
end
