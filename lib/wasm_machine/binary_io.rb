module WasmMachine
  class BinaryIO < ::StringIO
    # @return [Integer]
    def remain
      size - pos
    end

    # @param [Integer] n
    # @return [String]
    def read(n)
      raise WasmMachine::BinaryError if n > remain
      super
    end

    # @return [Integer]
    def readbyte
      super
    rescue EOFError
      raise WasmMachine::BinaryError
    end

    # @return [Integer]
    def read_u32
      u32 = 0
      offset = 0

      # https://webassembly.github.io/spec/core/binary/values.html#integers
      loop do
        b = readbyte
        u32 |= ((b & 0x7F) << offset)

        offset += 7
        break if b[7] == 0

        raise WasmMachine::BinaryError if offset >= 32
      end

      u32
    end

    # @return [Integer]
    def read_i32
      i32 = 0
      offset = 0

      loop do
        b = readbyte
        i32 |= ((b & 0x7F) << offset)

        offset += 7
        break if b[7] == 0

        raise WasmMachine::BinaryError if offset >= 32
      end

      if i32[offset - 1] == 1
        i32 | (~0 << offset)
      else
        i32
      end
    end

    # @return [Boolean]
    def read_flag
      b =readbyte
      raise WasmMachine::BinaryError if b != 0 && b != 1
      b == 1
    end

    # @see https://webassembly.github.io/spec/core/binary/values.html#binary-name
    # @return [String]
    def read_utf8
      read(read_u32).force_encoding(Encoding::UTF_8)
    end

    # @see https://webassembly.github.io/spec/core/binary/conventions.html#vectors
    # @yield Called for each element in vector
    # @return [Array<Object>]
    def read_vector
      Array.new(read_u32) do |i|
        yield i
      end
    end
  end
end
