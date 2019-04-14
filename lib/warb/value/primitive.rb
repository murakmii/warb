module WARB::Value
  class Primitive
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def clone
      self.class.new(@value)
    end

    def replace(value)
      @value = value
    end
  end
end
