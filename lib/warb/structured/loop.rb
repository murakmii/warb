module WARB::Structured
  class Loop < Block
    # @return [Integer]
    def continuation_pc
      # "loop" does forward jump:
      # https://webassembly.github.io/spec/core/syntax/instructions.html#control-instructions
      start_pc - 2
    end
  end
end
