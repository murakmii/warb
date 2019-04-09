module WARB::ControlFlow
  class Loop
    include WARB::ControlFlow::StructuredInstruction

    def before_block_index
      start_index - 2
    end
  end
end
