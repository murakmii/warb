module WasmMachine
  class Error < ::StandardError; end

  class BinaryError < Error
    def initialize(message = nil)
      super(message || "Malformed WebAssembly binary")
    end
  end
end
