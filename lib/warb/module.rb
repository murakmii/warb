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

      def read_table_section(io)
        io.read_vector { WARB::Table.from_io(io) }
      end

      def read_memory_section(io)
        io.read_vector { WARB::Memory.from_io(io) }
      end

      def read_code_section(io, functions)
        io.read_vector do |i|
          raise WARB::BinaryError unless functions[i]

          functions[i].set_code_from_io(io)
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
      @tables = []
      @customs = []

      @exported_functions = {}
      @exported_tables = {}
      @exported_memories = {}
      @exported_globals = {}

      @start_index = nil

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
          @tables = self.class.read_table_section(io)
        when MEMORY_SECTION_ID
          @memories = self.class.read_memory_section(io)
        when GLOBAL_SECTION_ID
          read_global_section(io)
        when EXPORT_SECTION_ID
          read_export_section(io)
        when START_SECTION_ID
          @start_index = io.read_u32
        when ELEMENT_SECTION_ID
          read_element_section(io)
        when CODE_SECTION_ID
          self.class.read_code_section(io, @functions)
        when DATA_SECTION_ID
          read_data_section(io)
        else
          unless section_id == CUSTOM_SECTION_ID
            raise WARB::BinaryError, "Unsupported section id: #{section_id}"
          end
        end

        raise WARB::BinaryError unless io.pos == expected_pos
      end
    end

    def type(index)
      @function_types[index] || raise(WARB::BinaryError)
    end

    def table(index)
      @tables[index] || raise(WARB::BinaryError)
    end

    def memory(index)
      @memories[index] || raise(WARB::BinaryError)
    end

    def function(index)
      @functions[index] || raise(WARB::BinaryError)
    end

    def global(index)
      @globals[index] || raise(WARB::BinaryError)
    end

    def exported_function_names
      @exported_functions.keys
    end

    def exported_function(name)
      WARB::ContextualFunction.new(
        self,
        function(@exported_functions[name] || raise(WARB::BinaryError))
      )
    end

    def start_function
      WARB::ContextualFunction.new(
        self,
        function(@start_index || raise(WARB::BinaryError))
      )
    end

    private

      def read_global_section(io)
        io.read_vector { @globals << WARB::Global.from_io(self, io) }
      end

      def read_element_section(io)
        io.read_vector do
          t = table(io.read_u32)
          offset = WARB::ConstantExpr.evaluate(self, io)

          raise WARB::BinaryError unless offset.is_a?(WARB::Value::I32)

          io.read_vector {|i| t[offset.value + i] = function(io.read_u32) }
        end
      end

      def read_data_section(io)
        io.read_vector do
          raise WARB::BinaryError if io.readbyte != 0 # Allowed only 0(default linear memory)
          offset = WARB::ConstantExpr.evaluate(self, io)

          raise WARB::BinaryError unless offset.is_a?(WARB::Value::I32)

          memory(0).store_data(offset.value, io.read(io.read_u32))
        end
      end

      def read_export_section(io)
        io.read_vector do
          name = io.read_utf8

          case io.readbyte
          when 0x00
            @exported_functions[name] = io.read_u32
          when 0x01
            @exported_tables[name] = io.read_u32
          when 0x02
            @exported_memories[name] = io.read_u32
          when 0x03
            @exported_globals[name] = io.read_u32
          else
            raise WARB::BinaryError
          end
        end
      end
  end
end
