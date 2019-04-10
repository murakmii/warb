module WARB::ControlFlow
  module StructuredInstruction
    def self.included(klass)
      klass.attr_reader :return_types, :start_index
      klass.attr_accessor :end_index
    end

    def initialize(return_types, start_index = -1)
      @return_types = return_types
      @start_index = start_index
    end

    def root?
      start_index == -1
    end
  end
end
