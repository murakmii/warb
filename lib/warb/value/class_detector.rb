module WARB::Value
  class ClassDetector
    def self.from_byte(byte)
      case byte
      when 0x7F
        WARB::Value::I32
      when 0x7E
        WARB::Value::I64
      when 0x7D
        WARB::Value::F32
      when 0x7C
        WARB::Value::F64
      else
        raise(WARB::BinaryError)
      end
    end
  end
end
