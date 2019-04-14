module WARB::Structured
  # The class represents "block".
  #
  # @see https://webassembly.github.io/spec/core/syntax/instructions.html#control-instructions
  class Block
    attr_reader :arity, :start_pc, :end_pc

    # @param [Array<Class>] arity
    # @param [Integer] start_pc
    def initialize(arity, start_pc = -1)
      @arity = arity
      @start_pc = start_pc
      @end_pc = nil
    end

    # @param [Integer] pc
    def set_end_pc(pc)
      @end_pc = pc
    end

    # @return [Integer]
    def continuation_pc
      @end_pc + 1
    end
  end
end
