module WARB
  class FunctionType
    attr_reader :arity, :return_arity

    def self.from_io(io)
      raise WARB::BinaryError unless io.readbyte == 0x60

      new(
        io.read_vector { WARB::Value::ClassDetector.from_byte(io.readbyte) },
        io.read_vector { WARB::Value::ClassDetector.from_byte(io.readbyte) },
      )
    end

    def initialize(arity, return_arity)
      raise WARB::BinaryError if return_arity.size > 1

      @arity = arity
      @return_arity = return_arity
    end

    def ==(other_ft)
      other_ft.is_a?(self.class) && other_ft.arity == arity && other_ft.return_arity == return_arity
    end

    def inspect
      "#<#{self.class} " \
      "(#{@arity.map(&:inspect).join(",")})=>" \
      "(#{@return_arity.map(&:inspect).join(",")})>" \
    end
  end
end
