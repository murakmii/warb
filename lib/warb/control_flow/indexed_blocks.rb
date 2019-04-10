module WARB::ControlFlow
  class IndexedBlocks
    BLOCK_CLASSES = [
      WARB::ControlFlow::Block,
      WARB::ControlFlow::Loop,
      WARB::ControlFlow::IfElse,
    ].freeze

    class << self
      def from_function_body(func)
        func.instructions.retain_pos do |io|
          io.rewind

          block = WARB::ControlFlow::Block.new(func.type.return_types)
          blocks = find_blocks(io, block)

          raise WARB::BinaryError unless io.eof?

          new(block, blocks)
        end
      end

      private

        def find_blocks(io, root)
          found = []
          stack = [root]

          until stack.empty? do
            instr = io.read_next_structured_instr

            case instr
            when 0x02, 0x03, 0x04
              blocktype = io.readbyte
              return_types = (blocktype == 0x40 ? [] : [WARB::ValueType.from_byte(blocktype)])
              stack << BLOCK_CLASSES[instr - 0x02].new(return_types, io.pos)

            when 0x05
              raise WARB::BinaryError unless stack.last.is_a?(WARB::ControlFlow::IfElse) &&
                    stack.last.else_start_index.nil?

              stack.last.else_start_index = io.pos

            when 0x0B
              stack.last.end_index = io.pos - 1
              found << stack.pop
            end
          end

          found
        end
    end

    attr_reader :root

    def initialize(root, blocks)
      @root = root
      @blocks = {}

      blocks.each {|b| @blocks[b.start_index] = b unless b.equal?(@root) }
    end

    def [](index)
      @blocks[index] || raise(WARB::BinaryError)
    end
  end
end
