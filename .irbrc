# Utility for IRB
def wasm(file)
  reader = WasmMachine::Binary::Reader.new(File.read(file))
  WasmMachine::Binary::Module.new(reader)
end
