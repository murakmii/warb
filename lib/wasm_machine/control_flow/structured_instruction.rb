module WasmMachine::ControlFlow
  module StructuredInstruction
    def self.included(klass)
      klass.attr_reader :arity, :start_index
      klass.attr_accessor :end_index, :nested_blocks
    end

    def initialize(arity, start_index)
      @arity = arity
      @start_index = start_index
      @nested_blocks = []
    end
  end
end
