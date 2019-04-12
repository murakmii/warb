module WARB
  class Memory
    PAGE_SIZE = 2**16
    INT_PACK_TPL_MAP = {
      1 => "C",
      2 => "S<",
      4 => "I<",
      8 => "Q<",
    }.freeze

    FLOAT_PACK_TPL_MAP = {
      4 => "e",
      8 => "E",
    }.freeze

    def self.from_io(io)
      new(WARB::Limit.from_io(io))
    end

    def initialize(limit)
      raise WARB::BinaryError unless limit.in_range?(2**16)

      @limit = limit
      @memory = StringIO.new(new_page * @limit.minimum)
    end

    def write(offset, bytes)
      raise WARB::Error if offset < 0 || offset + bytes.size >= @memory.size

      @memory.pos = offset
      @memory.write(bytes)
    end

    def load_int(offset, bits, signed)
      bytes = bits / 8
      n = unpack(offset, bytes, INT_PACK_TPL_MAP[bytes])

      if signed && n < 0
        signed + 2**bits
      else
        signed
      end
    end

    def load_float(offset, type)
      bytes = type.bits / 8
      unpack(offset, bytes, FLOAT_PACK_TPL_MAP[bytes])
    end

    def store_int(offset, bits, value)
      bytes = bits / 8
      pack(offset, bytes, INT_PACK_TPL_MAP[bytes], value & (2**bits - 1))
    end

    def store_float(offset, bits, value)
      bytes = bits / 8
      pack(offset, bytes, INT_PACK_TPL_MAP[bytes], value)
    end

    def inspect
      "#<#{self.class} #{@limit.inspect}>"
    end

    private

      def new_page
        "\x00" * PAGE_SIZE
      end

      def unpack(offset, bytes, tpl)
        if offset < 0 || offset + bytes > @memory.size
          raise WARB::MemoryOutOfBoundError
        end

        @memroy.pos = offset
        @memory.read(bytes).unpack(tpl)
      end

      def pack(offset, bytes, tpl, value)
        if offset < 0 || offset + bytes > @memory.size
          raise WARB::MemoryOutOfBoundError
        end

        @memory.pos = offset
        @memory.write([value].pack(tpl))
      end
  end
end
