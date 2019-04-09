module WARB::ControlFlow
  class Block
    include WARB::ControlFlow::StructuredInstruction

    BLOCK_CLASSES = {
      0x02 => self,
      0x03 => WARB::ControlFlow::Loop,
      0x04 => WARB::ControlFlow::IfElse,
    }

    class << self
      def from_function_body(function_type, io)
        block = new(function_type.return_type, 0)
        block.nested_blocks = decode_nested_blocks(io, block)

        raise WARB::BinaryError unless io.eof?

        block.end_index = io.pos - 1
        block
      end

      private

        def decode_arity(io)
          blocktype = io.readbyte
          blocktype == 0x40 ? nil : WARB::ValueType.from_byte(blocktype)
        end

        def decode_nested_blocks(io, current_block)
          blocks = []

          loop do
            instr = io.read_next_structured_instr

            case instr
            when 0x02, 0x03, 0x04
              block = BLOCK_CLASSES[instr].new(decode_arity(io), io.pos)
              block.nested_blocks = decode_nested_blocks(io, block)
              block.end_index = io.pos - 1
              blocks << block
            when 0x05
              raise WARB::BinaryError unless current_block.is_a?(WARB::ControlFlow::IfElse) && current_block.else_start_index.nil?

              current_block.else_start_index = io.pos
              current_block.else_nested_blocks = decode_nested_blocks(io, current_block)
              break
            when 0x0B
              break
            end
          end

          blocks
        end
    end
  end
end
