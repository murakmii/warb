IRB.conf[:SAVE_HISTORY] = 100

# Utility for IRB
def wasm(file)
  WARB::Module.new(File.read(file))
end
