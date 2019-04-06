module WasmMachine::ControlFlow
  class IfElse
    include WasmMachine::ControlFlow::StructuredInstruction

    attr_accessor :else_start_index, :else_nested_blocks
  end
end
