module WasmMachine
  class BinaryIO < ::StringIO
    SINGLE_LEB128_32_SKIPPER = ->(io) { io.skip_leb128(32) }
    DOUBLE_LEB128_32_SKIPPER = ->(io) { io.skip_leb128(32); io.skip_leb128(32) }
    BYTE_SKIPPER = ->(io) { io.pos += 1 }

    NON_STRUCTURED_INSTR_SKIPPER_MAP = Array.new(256) do |instr|
      case instr
      when 0x00, 0x01
        nil
      when 0x0C, 0x0D
        SINGLE_LEB128_32_SKIPPER
      when 0x0E
        ->(io) { (io.read_u32 + 1).times { io.skip_leb128(32) } }
      when 0x0F
        nil
      when 0x10
        SINGLE_LEB128_32_SKIPPER
      when 0x11
        ->(io) {
          io.skip_leb128(32)
          io.pos += 1
        }
      when 0x1A, 0x1B
        nil
      when 0x20..0x24
        SINGLE_LEB128_32_SKIPPER
      when 0x28..0x3E
        DOUBLE_LEB128_32_SKIPPER
      when 0x3F, 0x40
        BYTE_SKIPPER
      when 0x41
        SINGLE_LEB128_32_SKIPPER
      when 0x42
        ->(io) { io.skip_leb128(64) }
      when 0x43
        ->(io) { io.pos += 4 }
      when 0x44
        ->(io) { io.pos += 8 }
      when 0x45..0xBF
        nil
      else
        ->(_) { raise WasmMachine::BinaryError }
      end
    end

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
    def advance
      readbyte
    end

    # @param [Integer] bits
    def skip_leb128(bits)
      skipped_bits = 0
      loop do
        raise WasmMachine::BinaryError if skipped_bits >= bits
        break if readbyte[7] == 0
        skipped_bits += 8
      end
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

    # @return [Integer]
    def read_next_structured_instr
      loop do
        instr = readbyte
        if instr == 0x02 || instr == 0x03 || instr == 0x04 || instr == 0x05 || instr == 0x0B
          break instr
        else
          NON_STRUCTURED_INSTR_SKIPPER_MAP[instr]&.call(self)
        end
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
