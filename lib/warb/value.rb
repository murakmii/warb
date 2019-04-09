module WARB
  class Value
    attr_reader :type
    attr_accessor :value

    def initialize(type, value)
      @type = type
      @value = value
    end

    def inspect
      "#<#{self.class} #{@type.inspect} value:#{@value}>"
    end
  end
end
