module WARB
  class Instructions
    class << self
      def execute(s, instr)
        case instr

        #
        # Control instructions
        #

        when 0x00 then # unreachable
          raise WARB::Unreachable

        when 0x01 # nop
          nil

        when 0x02, 0x03 # block, loop
          s.f.func.body.readbyte
          s.push_label(s.f.func.blocks[s.f.pc])

        when 0x04 # if
          s.f.func.body.readbyte
          b = s.f.func.blocks[s.f.pc]
          s.push_label(b)
          s.f.func.body.pos = (s.pop_i32 == 0) ? b.else_start_pc : b.start_pc

        when 0x05 # else
          s.exit_label

        when 0x0B # end
          s.exit_label
          s.exit_current_frame if s.f.no_label?

        when 0x0C # br
          br(s, s.f.func.body.read_u32)

        when 0x0D # br_if
          label_index = s.f.func.body.read_u32
          br(s, label_index) unless s.pop_i32 == 0

        when 0x0E # br_table
          i = s.pop_i32
          label_index = nil

          s.f.func.body.read_u32.times do |j|
            if j == i
              label_index = s.f.func.body.read_u32
            else
              s.f.body.skip_leb128
            end
          end

          if label_index
            s.f.func.body.skip_leb128(32)
          else
            label_index = s.f.func.body.read_u32
          end

          br(s, label_index)

        when 0x0F # return
          s.return_current_frame

        when 0x10 # call
          s.push_new_frame(s.f.mod.function(s.f.func.body.read_u32))

        when 0x11 # call_indirect
          table = s.f.mod.table(0)
          raise WARB::BinaryError unless table.elem_type == :funcref

          f = table[s.pop_i32]
          raise WARB::BinaryError unless f.type == s.f.mod.type(s.f.func.body.read_u32)

          s.push_new_frame(f)

        #
        # Parametric Instructions
        #

        when 0x1A # drop
          s.pop_any_value

        when 0x1B # select
          c  = s.pop_i32
          v2 = s.pop_any_value
          v1 = s.pop_value(v2.class)
          s.push(c != 0 ? v1 : v2)

        #
        # Variable Instructions
        #

        when 0x20 # local.get
          s.push(s.f.get_local_var(s.f.func.body.read_u32))

        when 0x21 # local.set
          s.f.set_local_var(s.f.func.body.read_u32, s.pop)

        when 0x22 # local.tee
          s.f.set_local_var(s.f.func.body.read_u32, s.peek.clone)

        when 0x23 # global.get
          s.push(s.f.mod.global(s.f.func.body.read_u32).value.clone)

        when 0x24 # global.set
          g = s.f.mod.global(s.f.func.body.read_u32)
          raise WARB::BinaryError unless g.mutable?
          g.set(s.pop_value(g.value_class))

        #
        # Memory Instructions
        #

        when 0x28 then load_int(s, WARB::Value::I32, 4, false)
        when 0x29 then load_int(s, WARB::Value::I64, 8, false)
        when 0x2A then load_float(s, WARB::Value::F32)
        when 0x2B then load_float(s, WARB::Value::F64)
        when 0x2C then load_int(s, WARB::Value::I32, 1, true)
        when 0x2D then load_int(s, WARB::Value::I32, 1, false)
        when 0x2E then load_int(s, WARB::Value::I32, 2, true)
        when 0x2F then load_int(s, WARB::Value::I32, 2, false)
        when 0x30 then load_int(s, WARB::Value::I64, 1, true)
        when 0x31 then load_int(s, WARB::Value::I64, 1, false)
        when 0x32 then load_int(s, WARB::Value::I64, 2, true)
        when 0x33 then load_int(s, WARB::Value::I64, 2, false)
        when 0x34 then load_int(s, WARB::Value::I64, 4, true)
        when 0x35 then load_int(s, WARB::Value::I64, 4, false)

        when 0x36 then store_int(s, WARB::Value::I32, 4)
        when 0x37 then store_int(s, WARB::Value::I64, 8)
        when 0x38 then store_int(s, WARB::Value::F32)
        when 0x39 then store_int(s, WARB::Value::F64)
        when 0x3A then store_int(s, WARB::Value::I32, 1)
        when 0x3B then store_int(s, WARB::Value::I32, 2)
        when 0x3C then store_int(s, WARB::Value::I32, 1)
        when 0x3D then store_int(s, WARB::Value::I32, 2)
        when 0x3E then store_int(s, WARB::Value::I32, 4)

        when 0x3F # memory.size
          raise WARB::BinaryError unless s.f.func.body.readbyte == 0x00
          s.push(WARB::Value::I32.new(s.f.mod.memory(0).pages))

        when 0x40 # memory.grow
          raise WARB::BinaryError unless s.f.func.body.readbyte == 0x00

          n = s.pop_value(WARB::Value::I32)
          ret = s.f.mod.memory(0).grow!(n.value)
          n.replace(ret < 0 ? (ret + (1 << 32)) : ret)
          s.push(n)

        #
        # Numeric Instructions
        #

        when 0x41 # i32.const
          s.push(WARB::Value::I32.new(s.f.func.body.read_i32))

        when 0x42 # i64.const
          s.push(WARB::Value::I64.new(s.f.func.body.read_i64))

        when 0x43 # f32.const
          s.push(WARB::Value::F32.new(s.f.func.body.read_f32))

        when 0x44 # f64.const
          s.push(WARB::Value::F64.new(s.f.func.body.read_f64))

        # i32 itestop, irelop

        when 0x45 # i32.eqz
          i = s.pop_value(WARB::Value::I32)
          i.replace(i.value == 0 ? 1 : 0)
          s.push(i)

        when 0x46 # i32.eq
          c2 = s.pop_value(WARB::Value::I32)
          c1 = s.pop_value(WARB::Value::I32)
          s.push(WARB::Value::I32.new(c1 == c2 ? 1 : 0))

        when 0x47 # i32.ne
          c2 = s.pop_value(WARB::Value::I32)
          c1 = s.pop_value(WARB::Value::I32)
          s.push(WARB::Value::I32.new(c1 != c2 ? 1 : 0))

        when 0x48 # i32.lt_s
          c2 = s.pop_value(WARB::Value::I32).signed
          c1 = s.pop_value(WARB::Value::I32).signed
          s.push(WARB::Value::I32.new(c1 < c2 ? 1 : 0))

        when 0x49 # i32.lt_u
          c2 = s.pop_value(WARB::Value::I32).unsigned
          c1 = s.pop_value(WARB::Value::I32).unsigned
          s.push(WARB::Value::I32.new(c1 < c2 ? 1 : 0))

        when 0x4A # i32.gt_s
          c2 = s.pop_value(WARB::Value::I32).signed
          c1 = s.pop_value(WARB::Value::I32).signed
          s.push(WARB::Value::I32.new(c1 > c2 ? 1 : 0))

        when 0x4B # i32.gt_u
          c2 = s.pop_value(WARB::Value::I32).unsigned
          c1 = s.pop_value(WARB::Value::I32).unsigned
          s.push(WARB::Value::I32.new(c1 > c2 ? 1 : 0))

        when 0x4C # i32.le_s
          c2 = s.pop_value(WARB::Value::I32).signed
          c1 = s.pop_value(WARB::Value::I32).signed
          s.push(WARB::Value::I32.new(c1 <= c2 ? 1 : 0))

        when 0x4D # i32.le_u
          c2 = s.pop_value(WARB::Value::I32).unsigned
          c1 = s.pop_value(WARB::Value::I32).unsigned
          s.push(WARB::Value::I32.new(c1 <= c2 ? 1 : 0))

        when 0x4E # i32.ge_s
          c2 = s.pop_value(WARB::Value::I32).signed
          c1 = s.pop_value(WARB::Value::I32).signed
          s.push(WARB::Value::I32.new(c1 >= c2 ? 1 : 0))

        when 0x4F # i32.ge_u
          c2 = s.pop_value(WARB::Value::I32).unsigned
          c1 = s.pop_value(WARB::Value::I32).unsigned
          s.push(WARB::Value::I32.new(c1 >= c2 ? 1 : 0))

        # i64 itestop, irelop

        when 0x50 # i64.eqz
          s.push(WARB::Value::I32.new(s.pop_value(WARB::Value::I64).value == 0 ? 1 : 0))

        when 0x51 # i64.eq
          c2 = s.pop_value(WARB::Value::I64)
          c1 = s.pop_value(WARB::Value::I64)
          s.push(WARB::Value::I32.new(c1 == c2 ? 1 : 0))

        when 0x52 # i64.ne
          c2 = s.pop_value(WARB::Value::I64)
          c1 = s.pop_value(WARB::Value::I64)
          s.push(WARB::Value::I32.new(c1 != c2 ? 1 : 0))

        when 0x53 # i64.lt_s
          c2 = s.pop_value(WARB::Value::I64).signed
          c1 = s.pop_value(WARB::Value::I64).signed
          s.push(WARB::Value::I32.new(c1 < c2 ? 1 : 0))

        when 0x54 # i64.lt_u
          c2 = s.pop_value(WARB::Value::I64).unsigned
          c1 = s.pop_value(WARB::Value::I64).unsigned
          s.push(WARB::Value::I32.new(c1 < c2 ? 1 : 0))

        when 0x55 # i64.gt_s
          c2 = s.pop_value(WARB::Value::I64).signed
          c1 = s.pop_value(WARB::Value::I64).signed
          s.push(WARB::Value::I32.new(c1 > c2 ? 1 : 0))

        when 0x56 # i64.gt_u
          c2 = s.pop_value(WARB::Value::I64).unsigned
          c1 = s.pop_value(WARB::Value::I64).unsigned
          s.push(WARB::Value::I32.new(c1 > c2 ? 1 : 0))

        when 0x57 # i64.le_s
          c2 = s.pop_value(WARB::Value::I64).signed
          c1 = s.pop_value(WARB::Value::I64).signed
          s.push(WARB::Value::I32.new(c1 <= c2 ? 1 : 0))

        when 0x58 # i64.le_u
          c2 = s.pop_value(WARB::Value::I64).unsigned
          c1 = s.pop_value(WARB::Value::I64).unsigned
          s.push(WARB::Value::I32.new(c1 <= c2 ? 1 : 0))

        when 0x59 # i64.ge_s
          c2 = s.pop_value(WARB::Value::I64).signed
          c1 = s.pop_value(WARB::Value::I64).signed
          s.push(WARB::Value::I32.new(c1 >= c2 ? 1 : 0))

        when 0x5A # i64.ge_u
          c2 = s.pop_value(WARB::Value::I64).unsigned
          c1 = s.pop_value(WARB::Value::I6d).unsigned
          s.push(WARB::Value::I32.new(c1 >= c2 ? 1 : 0))

        # f32 frelop

        when 0x5B # f32.eq
          c2 = s.pop_value(WARB::Value::F32).value
          c1 = s.pop_value(WARB::Value::F32).value
          s.push(WARB::Value::I32.new(c1 == c2 ? 1 : 0))

        when 0x5C # f32.ne
          c2 = s.pop_value(WARB::Value::F32).value
          c1 = s.pop_value(WARB::Value::F32).value
          s.push(WARB::Value::I32.new(c1 != c2 ? 1 : 0))

        when 0x5D # f32.lt
          c2 = s.pop_value(WARB::Value::F32).value
          c1 = s.pop_value(WARB::Value::F32).value
          s.push(WARB::Value::I32.new(c1 < c2 ? 1 : 0))

        when 0x5E # f32.gt
          c2 = s.pop_value(WARB::Value::F32).value
          c1 = s.pop_value(WARB::Value::F32).value
          s.push(WARB::Value::I32.new(c1 > c2 ? 1 : 0))

        when 0x5F # f32.le
          c2 = s.pop_value(WARB::Value::F32).value
          c1 = s.pop_value(WARB::Value::F32).value
          s.push(WARB::Value::I32.new(c1 <= c2 ? 1 : 0))

        when 0x60 # f32.ge
          c2 = s.pop_value(WARB::Value::F32).value
          c1 = s.pop_value(WARB::Value::F32).value
          s.push(WARB::Value::I32.new(c1 >= c2 ? 1 : 0))

        # f64 frelop

        when 0x61 # f64.eq
          c2 = s.pop_value(WARB::Value::F64).value
          c1 = s.pop_value(WARB::Value::F64).value
          s.push(WARB::Value::I32.new(c1 == c2 ? 1 : 0))

        when 0x62 # f64.ne
          c2 = s.pop_value(WARB::Value::F64).value
          c1 = s.pop_value(WARB::Value::F64).value
          s.push(WARB::Value::I32.new(c1 != c2 ? 1 : 0))

        when 0x63 # f64.lt
          c2 = s.pop_value(WARB::Value::F64).value
          c1 = s.pop_value(WARB::Value::F64).value
          s.push(WARB::Value::I32.new(c1 < c2 ? 1 : 0))

        when 0x64 # f64.gt
          c2 = s.pop_value(WARB::Value::F64).value
          c1 = s.pop_value(WARB::Value::F64).value
          s.push(WARB::Value::I32.new(c1 > c2 ? 1 : 0))

        when 0x65 # f64.le
          c2 = s.pop_value(WARB::Value::F64).value
          c1 = s.pop_value(WARB::Value::F64).value
          s.push(WARB::Value::I32.new(c1 <= c2 ? 1 : 0))

        when 0x66 # f64.ge
          c2 = s.pop_value(WARB::Value::F64).value
          c1 = s.pop_value(WARB::Value::F64).value
          s.push(WARB::Value::I32.new(c1 >= c2 ? 1 : 0))

        when 0x6A # i32.add
          c2 = s.pop_value(WARB::Value::I32)
          c1 = s.pop_value(WARB::Value::I32)
          s.push(c1 + c2)

        else
          raise WARB::BinaryError
        end
      end

      private

        def br(stack, label_index)
          block = stack.break_label(label_index)
          stack.current_frame.jump_to(block.continuation_pc)
        end

        def read_memarg(stack)
          stack.current_frame.func.body.skip_leb128(32)
          stack.current_frame.func.body.read_u32 + stack.pop_i32
        end

        def load_int(stack, value_class, bytes, signed)
          i = stack.current_frame.mod.memory(0).load_int(read_memarg(stack), bytes, signed)
          stack.push(value_class.new(i))
        end

        def load_float(stack, value_class)
          f = stack.current_frame.mod.memory(0).load_float(read_memarg(stack), value_class::BYTES)
          stack.push(value_class.new(f))
        end

        def store_int(stack, value_class, bytes)
          i = stack.pop_value(value_class).value
          stack.current_frame.mod.memory(0).store_int(read_memarg(stack), bytes, i)
        end

        def store_float(stack, value_class)
          f = stack.pop_value(value_class).value
          stack.current_frame.mod.memory(0).store_float(read_memarg(stack), value_class::BYTES, f)
        end
    end
  end
end
