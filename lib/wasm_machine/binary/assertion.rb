module WasmMachine::Binary
  module Assertion
    # @param [Boolean] condition
    # @param [String] message
    def assert(condition, message = nil)
      raise WasmMachine::BinaryError, message unless condition
    end
  end
end
