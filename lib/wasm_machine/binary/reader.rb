module WasmMachine::Binary
  # Reader to provide reading operation(e.g. reading LEB128)
  class Reader
    extend Forwardable

    def_delegators :@binary, :eof?

    # @param [String] binary WebAssembly
    def initialize(binary)
      @binary = StringIO.new(binary)
    end

    # @return [Integer]
    def remain
      @binary.size - @binary.pos
    end

    # @param [Integer] n
    # @return [String]
    def read(n)
      raise WasmMachine::BinaryError if n > remain
      @binary.read(n)
    end

    # @param [Integer] n
    # @return [WasmMachine::Binary::Reader] New reader for next n bytes
    def new_reader_for(n)
      self.class.new(read(n))
    end

    # @return [String]
    def read_until_eof
      raise WasmMachine::BinaryError if remain == 0
      @binary.read
    end

    # @return [Integer]
    def read_byte
      @binary.readbyte
    rescue EOFError
      raise WasmMachine::BinaryError
    end

    # @return [Integer]
    def read_u32
      u32 = 0
      offset = 0

      # https://webassembly.github.io/spec/core/binary/values.html#integers
      loop do
        b = read_byte
        u32 |= ((b & 0x7F) << offset)

        break if b[7] == 0
        offset += 7
      end

      u32
    end

    # @see https://webassembly.github.io/spec/core/binary/values.html#binary-name
    # @return [String]
    def read_utf8
      read(read_u32).force_encoding("UTF-8")
    end

    # @see https://webassembly.github.io/spec/core/binary/conventions.html#vectors
    # @yield Called for each element in vector
    # @return [Array<Object>]
    def read_vector
      Array.new(read_u32) do |i|
        yield i
      end
    end

    # @return [Array<Integer>] array of instructions
    def read_const_expr
      expr = []

      loop do
        expr << read_byte
        break if expr.last == 0x0B
      end

      expr
    end
  end
end
