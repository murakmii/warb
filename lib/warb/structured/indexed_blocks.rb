module WARB::Structured
  # We find beforehand blocks and do indexing by starting position of program counter.
  class IndexedBlocks
    STRUCTURED_CLASSES = [
      WARB::Structured::Block,
      WARB::Structured::Loop,
      WARB::Structured::IfElse,
    ].freeze

    class << self
      # @param [WARB::Function] func
      def from_function_body(func)
        # Invocation creates implicit block. So, we create that as root.
        # https://webassembly.github.io/spec/core/exec/instructions.html#invocation-of-function-address
        root = WARB::Structured::Block.new(func.type.return_arity)
        blocks = find_blocks(func.body, root)

        new(root, blocks)
      end

      private

        # @param [WARB::ModuleIO] io function body
        # @param [WARB::Structured::Block] root
        # @return [Array<WARB::Structured::Block>]
        def find_blocks(io, root)
          io.retain_pos do
            blocks = []
            stack  = [root]

            until stack.empty? do
              instr = io.read_next_structured_instr

              case instr
              when 0x02, 0x03, 0x04
                blocktype = io.readbyte
                arity = (blocktype == 0x40 ? [] : [WARB::Value::ClassDetector.from_byte(blocktype)])
                stack << STRUCTURED_CLASSES[instr - 0x02].new(arity, io.pc)

              when 0x05
                raise WARB::BinaryError unless stack.last.is_a?(WARB::Structured::IfElse) && !stack.last.exists_else?
                stack.last.set_else_start_pc(io.pc)

              when 0x0B
                stack.last.set_end_pc(io.pc - 1)
                blocks << stack.pop
              end
            end

            raise WARB::BinaryError unless io.eof?

            blocks
          end
        end
    end

    attr_reader :root

    # @param [WARB::Structured::Block] root
    # @param [Array<WARB::Structured::Block>] blocks
    def initialize(root, blocks)
      @root = root
      @blocks = {}

      blocks.each {|b| @blocks[b.start_pc] = b }
      blocks.delete(@root.start_pc)
    end

    # @param [Integer] pc
    # @return [WARB::Structured::Block]
    def [](pc)
      @blocks[pc]
    end
  end
end
