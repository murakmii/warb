module WasmMachine
  class Memory
    PAGE_SIZE = 2**16

    def self.from_io(io)
      new(WasmMachine::Limit.from_io(io))
    end

    def initialize(limit)
      raise WasmMachine::BinaryError unless limit.in_range?(2**16)

      @limit = limit
      @linear = StringIO.new(new_page * @limit.minimum)
    end

    def write(offset, bytes)
      raise WasmMachine::Error if offset < 0 || offset + bytes.size >= @linear.size

      @linear.pos = offset
      @linear.write(bytes)
    end

    def inspect
      "#<#{self.class} #{@limit.inspect}>"
    end

    private

      def new_page
        "\x00" * PAGE_SIZE
      end
  end
end
