module WasmMachine::Binary
  # Representation of "Module"
  #
  # @see https://webassembly.github.io/spec/core/binary/modules.html#binary-module
  class Module
    MAGIC_AND_VERSION = "\x00\x61\x73\x6D\x01\x00\x00\x00"
    SECTIONS = {
      0  => WasmMachine::Binary::Section::CustomSection,
      1  => WasmMachine::Binary::Section::TypeSection,
      2  => WasmMachine::Binary::Section::ImportSection,
      3  => WasmMachine::Binary::Section::FunctionSection,
      4  => WasmMachine::Binary::Section::TableSection,
      5  => WasmMachine::Binary::Section::MemorySection,
      6  => WasmMachine::Binary::Section::GlobalSection,
      7  => WasmMachine::Binary::Section::ExportSection,
      8  => WasmMachine::Binary::Section::StartSection,
      9  => WasmMachine::Binary::Section::ElementSection,
      10 => WasmMachine::Binary::Section::CodeSection,
      11 => WasmMachine::Binary::Section::DataSection,
    }

    attr_reader :sections

    # @param [WasmMachine::Binary::Reader] reader
    def initialize(reader)
      unless reader.read(MAGIC_AND_VERSION.length) == MAGIC_AND_VERSION
        raise WasmMachine::BinaryError
      end

      @sections = []
      last_id = 0

      while !reader.eof?
        section_id = reader.read_byte
        raise WasmMachine::BinaryError if section_id < last_id

        section_class = SECTIONS[section_id]
        if section_class
          section_reader = reader.new_reader_for(reader.read_u32)
          @sections << section_class.new(section_reader)

          raise WasmMachine::BinaryError unless section_reader.eof?
          last_id = section_id
        else
          raise WasmMachine::BinaryError, "Unsupported section id: #{section_id}"
        end
      end
    end

    # @return [Hash]
    def to_h
      {
        sections: sections.map do |sec|
          { section_name: sec.class.name.split("::").last.sub(/Section$/, "").downcase }.merge(sec.to_h)
        end
      }
    end
  end
end
