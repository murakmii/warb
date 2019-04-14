module WARB
  class Memory
    PAGE_SIZE = 2**16

    def self.from_io(io)
      new(WARB::Limit.from_io(io))
    end

    def initialize(limit)
      raise WARB::BinaryError unless limit.in_range?(2**16)

      @limit = limit
      @memory = StringIO.new(new_page(@limit.minimum))
    end

    def pages
      @memory.size / PAGE_SIZE
    end

    def grow!(n)
      # TODO: more limitation
      if @limit.maximum && pages + n > @limit.maximum
        -1
      else
        @memory.pos = @memory.size
        @memory.write(new_page(n))
        pages
      end
    end

    def load_int(offset, bytes, signed)
      n = unpack_from(offset, bytes, int_template(bytes))

      if signed && n < 0
        signed + (1 << (bytes * 8))
      else
        signed
      end
    end

    def load_float(offset, bytes)
      unpack_from(offset, bytes, float_template(bytes))
    end

    def store_data(offset, data)
      assert_valid_access!(offset, data.size)

      @memory.pos = offset
      @memory.write(data)
    end

    def store_int(offset, bytes, value)
      pack_to(offset, bytes, int_template(bytes), value & ((1 << (bytes * 8)) - 1))
    end

    def store_float(offset, bytes, value)
      pack_to(offset, bytes, float_template(bytes), value)
    end

    def inspect
      "#<#{self.class} #{@limit.inspect}>"
    end

    private

      def new_page(n)
        ("\x00" * PAGE_SIZE * n)
      end

      def assert_valid_access(offset, bytes)
        raise WARB::MemoryOutOfBoundError if offset < 0 || offset + bytes > @memory.size
      end

      def int_template(bytes)
        case bytes
        when 1
          "C"
        when 2
          "S<"
        when 4
          "I<"
        when 8
          "Q<"
        else
          raise ArgumentError, "Invalid integer bytes: #{bytes}"
        end
      end

      def float_template(bytes)
        case bytes
        when 4
          "e"
        when 8
          "E"
        else
          raise ArgumentError, "Invalid float bytes: #{bytes}"
        end
      end

      def unpack_from(offset, bytes, tpl)
        assert_valid_access!(offset, bytes)

        @memroy.pos = offset
        @memory.read(bytes).unpack(tpl)
      end

      def pack_to(offset, bytes, tpl, value)
        assert_valid_access!(offset, bytes)

        @memory.pos = offset
        @memory.write([value].pack(tpl))
      end
  end
end
