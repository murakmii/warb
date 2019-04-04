module WasmMachine
  class Custom
    attr_reader :name, :bytes

    def self.from_io(io, size)
      start_pos = io.pos
      name = io.read_utf8

      new(name, io.read(size - (io.pos - start_pos)))
    end

    def initialize(name, bytes)
      @name = name
      @bytes = bytes
    end

    def inspect
      "<#{self.class} name:#{@name} bytes:#{@bytes.size}>"
    end
  end
end
