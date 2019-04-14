module WARB
  class Function
    attr_reader :type, :locals, :blocks, :body

    def initialize(type)
      @type = type
      @locals = []
      @body = nil
      @blocks = nil
    end

    def set_code_from_io(io)
      size = io.read_u32
      pos = io.pos

      io.read_vector do
        @locals.concat(
          Array.new(io.read_u32, WARB::Value::ClassDetector.from_byte(io.readbyte))
        )
      end

      @body = WARB::ModuleIO.new(io.read(size - (io.pos - pos)))
      @blocks = WARB::Structured::IndexedBlocks.from_function_body(self)
    end

    def inspect
      "#<#{self.class} locals:#{@locals.size} instr:#{@body.size}>"
    end
  end
end
