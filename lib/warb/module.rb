module WARB
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

    attr_reader :functions

    class << self
      def from_file(file)
        new(File.read(file))
      end

      def read_type_section(io)
        io.read_vector { WARB::FunctionType.from_io(io) }
      end

      def read_function_section(io, function_types)
        io.read_vector do
          typeidx = io.read_u32
          raise WARB::BinaryError if typeidx >= function_types.size

          WARB::Function.new(function_types[typeidx])
        end
      end

      def read_memory_section(io)
        io.read_vector { WARB::Memory.from_io(io) }
      end

      def read_global_section(io)
        io.read_vector { WARB::Global.from_io(io) }
      end

      def read_code_section(io, functions)
        io.read_vector do |i|
          raise WARB::BinaryError unless functions[i]

          functions[i].set_code_from_io(io)
        end
      end

      def read_data_section(io, memories)
        io.read_vector do
          raise WARB::BinaryError if io.readbyte != 0 # Allowed only 0(default linear memory)

          memories.first.write(
            WARB::ConstantExpr.evaluate(io),
            io.read(io.read_u32),
          )
        end
      end

      def read_stub(io, size)
        io.read(size)
      end
    end

    def initialize(binary)
      io = WARB::ModuleIO.new(binary)

      unless io.read(MAGIC_AND_VERSION.length) == MAGIC_AND_VERSION
        raise WARB::BinaryError, "Invalid header"
      end

      @function_types = []
      @functions = []
      @memories = []
      @globals = []
      @customs = []

      last_id = 0
      until io.eof? do
        section_id = io.readbyte
        size = io.read_u32
        expected_pos = io.pos + size

        if section_id == CUSTOM_SECTION_ID
          @customs << WARB::Custom.from_io(io, size)
        else
          raise WARB::BinaryError if section_id < last_id
          last_id = section_id
        end

        case section_id
        when TYPE_SECTION_ID
          @function_types = self.class.read_type_section(io)
        when IMPORT_SECTION_ID
          self.class.read_stub(io, size)
        when FUCNTION_SECTION_ID
          @functions = self.class.read_function_section(io, @function_types)
        when TABLE_SECTION_ID
          self.class.read_stub(io, size)
        when MEMORY_SECTION_ID
          @memories = self.class.read_memory_section(io)
        when GLOBAL_SECTION_ID
          @globals = self.class.read_global_section(io)
        when EXPORT_SECTION_ID
          self.class.read_stub(io, size)
        when START_SECTION_ID
          self.class.read_stub(io, size)
        when ELEMENT_SECTION_ID
          self.class.read_stub(io, size)
        when CODE_SECTION_ID
          self.class.read_code_section(io, @functions)
        when DATA_SECTION_ID
          self.class.read_data_section(io, @memories)
        else
          unless section_id == CUSTOM_SECTION_ID
            raise WARB::BinaryError, "Unsupported section id: #{section_id}"
          end
        end

        raise WARB::BinaryError unless io.pos == expected_pos
      end
    end

    def memory(index)
      @memory[index] || raise(WARB::BinaryError)
    end
  end
end
