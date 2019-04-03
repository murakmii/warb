module WasmMachine
  class Function
    def initialize(type)
      @type = type
      @locals = []
      @expr = nil
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

      @expr = io.read(size - (io.pos - pos))
    end

    def inspect
      "#<#{self.class} locals:#{@locals.size} expr:#{@expr.size}>"
    end
  end
end
