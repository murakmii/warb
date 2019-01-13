module WasmMachine::Binary::Section
  # Representation of "Import Section"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#import-section
  class ImportSection
    # Representation of "Import"
    #
    # @see https://webassembly.github.io/spec/core/binary/modules.html#binary-import
    class Import
      attr_reader :module_name, :name, :imported, :value

      # @param [WasmMachine::Binary::Reader] reader
      def initialize(reader)
        @module_name = reader.read_utf8
        @name = reader.read_utf8
        @imported = reader.read_byte

        case @imported
        when 0x00
          @value = reader.read_u32
        when 0x01
          @value = WasmMachine::Binary::TableType.new(reader)
        when 0x02
          @value = WasmMachine::Binary::MemoryType.new(reader)
        when 0x03
          @value = WasmMachine::Binary::GlobalType.new(reader)
        else
          raise WasmMachine::BinaryError, "Unsupport import description: 0x#{@imported.to_s(16).upcase}"
        end
      end

      # @return [String]
      def inspect
        "#<Import mod:#{module_name} name:#{name} #{value}>"
      end

      # @return [Hash]
      def to_h
        { module_name: module_name, name: name, imported: imported, value: (value.is_a?(Integer) ? value : value.to_h) }
      end
    end

    attr_reader :imports

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      @imports = reader.read_vector { Import.new(reader) }
    end

    # @return [String]
    def inspect
      "#<ImportSection imports:#{imports}>"
    end

    # @return [Hash]
    def to_h
      { imports: imports.map(&:to_h) }
    end
  end
end
