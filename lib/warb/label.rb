module WARB
  class Label
    attr_reader :block

    def initialize(block)
      @block = block
    end
  end
end
