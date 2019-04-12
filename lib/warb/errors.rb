module WARB
  class Error < ::StandardError; end
  class BinaryError < Error; end

  class Trap < Error; end
  class MemoryOutOfBoundError < Trap; end
end
