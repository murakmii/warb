module WasmMachine
  class Module
    MAGIC_AND_VERSION = "\x00\x61\x73\x6D\x01\x00\x00\x00"

    CUSTOM_SECTION_ID   = 0
    TYPE_SECTION_ID     = 1
    IMPORT_SECTION_ID   = 2
    FUCNTION_SECTION_ID = 3
    TABLE_SECTION_ID    = 4
    MEMORY_SECTION_ID   = 5
    GLOBAL_SECTION_ID   = 6
    EXPORT_SECTION_ID   = 7
    START_SECTION_ID    = 8
    ELEMENT_SECTION_ID  = 9
    CODE_SECTION_ID     = 10
    DATA_SECTION_ID     = 11

    class << self
      # Read custom section(Currently, this method ignore custom section)
      #
      # @param [BinaryIO] io
      # @param [Integer] size
      def read_custom_section(io, size)
        io.read_utf8
        io.read(size)
      end

      def read_type_section(io, _)
        io.read_vector { WasmMachine::FunctionType.from_io(io) }
      end

      def read_memory_section(io, _)
        io.read_vector { WasmMachine::Memory.from_io(io) }
      end

      def read_global_section(io, _)
        io.read_vector { WasmMachine::Global.from_io(io) }
      end

      def read_stub(io, size)
        io.read(size)
      end
    end

    def initialize(binary)
      io = WasmMachine::BinaryIO.new(binary)

      unless io.read(MAGIC_AND_VERSION.length) == MAGIC_AND_VERSION
        raise WasmMachine::BinaryError, "Invalid header"
      end

      @function_types = []
      @functions = []
      @memories = []
      @globals = []

      last_id = 0
      until io.eof? do
        section_id = io.readbyte
        raise WasmMachine::BinaryError if section_id < last_id

        size = io.read_u32
        expected_pos = io.pos + size

        case section_id
        when CUSTOM_SECTION_ID
          self.class.read_custom_section(io, size)
        when TYPE_SECTION_ID
          @function_types = self.class.read_type_section(io, size)
        when IMPORT_SECTION_ID
          self.class.read_stub(io, size)
        when FUCNTION_SECTION_ID
          self.class.read_stub(io, size)
        when TABLE_SECTION_ID
          self.class.read_stub(io, size)
        when MEMORY_SECTION_ID
          @memories = self.class.read_memory_section(io, size)
        when GLOBAL_SECTION_ID
          @globals = self.class.read_global_section(io, size)
        when EXPORT_SECTION_ID
          self.class.read_stub(io, size)
        when START_SECTION_ID
          self.class.read_stub(io, size)
        when ELEMENT_SECTION_ID
          self.class.read_stub(io, size)
        when CODE_SECTION_ID
          self.class.read_stub(io, size)
        when DATA_SECTION_ID
          self.class.read_stub(io, size)
        else
          raise WasmMachine::BinaryError, "Unsupported section id: #{section_id}"
        end

        raise WasmMachine::BinaryError unless io.pos == expected_pos
        last_id = section_id
      end
    end
  end
end
