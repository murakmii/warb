module WARB
  class ConstantExpr
    def self.evaluate(mod, io)
      instr = io.readbyte
      value =
        case instr
        when 0x23
          mod.global(io.read_u32).value.clone
        when 0x41
          WARB::Value::I32.new(io.read_i32)
        when 0x42
          WARB::Value::I64.new(io.read_i64)
        when 0x43
          WARB::Value::F32.new(s.f.func.body.read_f32)
        when 0x44
          WARB::Value::F64.new(s.f.func.body.read_f64)
        else
          raise WARB::BinaryError
        end

      io.readbyte == 0x0B ? value : raise(WARB::BinaryError)
    end
  end
end
