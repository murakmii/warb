module WARB::ControlFlow
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

    def flatten_nested_blocks
      flatten = { start_index => self }
      nested_blocks.each do |block|
        flatten[block.start_index] = block
        flatten.merge!(block.flatten_nested_blocks)
      end
      flatten
    end
  end
end
