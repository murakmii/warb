module WasmMachine
  class Memory
    def self.from_io(io)
      new(WasmMachine::Limit.from_io(io))
    end

    def initialize(limit)
      raise WasmMachine::BinaryError unless limit.in_range?(2**16)

      @limit = limit
    end

    def inspect
      "#<#{self.class} #{@limit.inspect}>"
    end
  end
end
