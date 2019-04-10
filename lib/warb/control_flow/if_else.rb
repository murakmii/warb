module WARB::ControlFlow
  class IfElse
    include WARB::ControlFlow::StructuredInstruction

    attr_accessor :else_start_index
  end
end
