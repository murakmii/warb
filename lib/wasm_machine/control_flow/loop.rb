module WasmMachine::ControlFlow
  class Loop
    include WasmMachine::ControlFlow::StructuredInstruction

    def before_block_index
      start_index - 2
    end
  end
end
