# Utility for IRB
def wasm(file)
  WasmMachine::Module.new(File.read(file))
end
