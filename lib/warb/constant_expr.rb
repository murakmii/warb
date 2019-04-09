module WARB
  class ConstantExpr
    def self.evaluate(io)
      instr = io.readbyte
      value =
        case instr
        when 0x41
          io.read_i32
        when 0x42
          io.read_i64
        else
          # TODO: support f32, f64, global.get
          raise WARB::BinaryError, "Instruction:0x#{instr.to_s(16).upcase} is NOT supported"
        end

      io.readbyte == 0x0B ? value : raise(WARB::BinaryError)
    end
  end
end
