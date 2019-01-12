module WasmMachine
  class Error < ::StandardError; end

  class BinaryError < Error
    def initialize(message = "Malformed WebAssembly binary")
      super
    end
  end
end
