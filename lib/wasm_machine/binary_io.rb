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
      read_unsigned_leb128(32)
    end

    # @return [Integer]
    def read_u64
      read_unsigned_leb128(64)
    end

    # @return [Integer]
    def read_i32
      read_signed_leb128(32)
    end

    # @return [Integer]
    def read_i64
      read_signed_leb128(64)
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

    private

      # @param [Integer]
      # @return [Integer]
      def read_unsigned_leb128(bits)
        unsigned = 0
        offset = 0

        # https://webassembly.github.io/spec/core/binary/values.html#integers
        loop do
          b = readbyte
          unsigned |= ((b & 0x7F) << offset)

          offset += 7
          break if b[7] == 0

          raise WasmMachine::BinaryError if offset >= bits
        end

        unsigned
      end

      # @param [Integer]
      # @return [Integer]
      def read_signed_leb128(bits)
        signed = 0
        offset = 0

        loop do
          b = readbyte
          signed |= ((b & 0x7F) << offset)

          offset += 7
          break if b[7] == 0

          raise WasmMachine::BinaryError if offset >= bits
        end

        if signed[offset - 1] == 1
          signed | (~0 << offset)
        else
          signed
        end
      end
  end
end
