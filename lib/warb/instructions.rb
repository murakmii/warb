module WARB
  class Instructions
    MAP = Array.new(256) do |instr|
      case instr
      when 0x02, 0x03
        ->(_, stack, frame) {
          frame.func.instructions.readbyte
          stack.push_label(frame.func.blocks[frame.func.instructions.pos])
        }

      when 0x0B
        ->(_, stack, frame) {
          popped_block = stack.pop_inner_most_label
          if stack.no_label_on_current_frame?
            stack.pop_current_frame
          else
            frame.jump_to_end_of_block(popped_block)
          end
        }

      when 0x0C
        ->(_, stack, frame) {
          block = stack.pop_label(frame.func.instructions.read_u32)
          frame.jump_to_continuation_of_block(block)
        }

      when 0x0D
        ->(mod, stack, frame) {
          nth = frame.func.instructions.read_u32
          raise WARB::BinaryError unless stack.peek.is_a?(WARB::Value) && stack.peek.type == WARB::ValueType.i32

          v = stack.pop.value
          if v != 0
            frame.jump_to_continuation_of_block(stack.pop_label(nth))
          end
        }

      when 0x20
        ->(_, stack, frame) {
          idx = frame.func.instructions.read_u32
          raise WARB::BinaryError unless frame.local_vars[idx]
          stack.push(frame.local_vars[idx])
        }

      when 0x21
        ->(_, stack, frame) {
          idx = frame.func.instructions.read_u32
          raise WARB::BinaryError unless frame.local_vars[idx]
          raise WARB::BinaryError unless stack.peek.is_a?(WARB::Value)

          frame.local_vars[idx] = stack.pop
        }

      when 0x22
        ->(_, stack, frame) {
          idx = frame.func.instructions.read_u32
          raise WARB::BinaryError unless frame.local_vars[idx]
          raise WARB::BinaryError unless stack.peek.is_a?(WARB::Value)

          frame.local_vars[idx] = stack.peek
        }

      # load
      when 0x28 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i32, 32, false) }
      when 0x29 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i64, 64, false) }
      when 0x2A then ->(mod, stack, frame) { load_float_in_memory(mod, stack, frame, WARB::ValueType.f32) }
      when 0x2B then ->(mod, stack, frame) { load_float_in_memory(mod, stack, frame, WARB::ValueType.f64) }
      when 0x2C then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i32, 8, true) }
      when 0x2D then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i32, 8, false) }
      when 0x2E then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i32, 16, true) }
      when 0x2F then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i32, 16, false) }
      when 0x30 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i64, 8, true) }
      when 0x31 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i64, 8, false) }
      when 0x32 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i64, 16, true) }
      when 0x33 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i64, 16, false) }
      when 0x34 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i64, 32, true) }
      when 0x35 then ->(mod, stack, frame) { load_int_in_memory(mod, stack, frame, WARB::ValueType.i64, 32, false) }

      # store
      when 0x36 then ->(mod, stack, frame) { store_int_to_memory(mod, stack, frame, WARB::ValueType.i32, 32) }
      when 0x37 then ->(mod, stack, frame) { store_int_to_memory(mod, stack, frame, WARB::ValueType.i64, 64) }
      when 0x38 then ->(mod, stack, frame) { store_float_to_memory(mod, stack, frame, WARB::ValueType.f32) }
      when 0x39 then ->(mod, stack, frame) { store_float_to_memory(mod, stack, frame, WARB::ValueType.f64) }
      when 0x3A then ->(mod, stack, frame) { store_int_to_memory(mod, stack, frame, WARB::ValueType.i32, 8) }
      when 0x3B then ->(mod, stack, frame) { store_int_to_memory(mod, stack, frame, WARB::ValueType.i32, 16) }
      when 0x3C then ->(mod, stack, frame) { store_int_to_memory(mod, stack, frame, WARB::ValueType.i64, 8) }
      when 0x3D then ->(mod, stack, frame) { store_int_to_memory(mod, stack, frame, WARB::ValueType.i64, 16) }
      when 0x3E then ->(mod, stack, frame) { store_int_to_memory(mod, stack, frame, WARB::ValueType.i64, 32) }

      when 0x41
        ->(_, stack, frame) {
          v = frame.func.instructions.read_i32
          stack.push_value(WARB::ValueType.i32, v)
        }

      when 0x48
        ->(_, stack, frame) {
          t2 = stack.pop
          raise WARB::BinaryError unless t2.is_a?(WARB::Value) && t2.type == WARB::ValueType.i32

          t1 = stack.pop
          raise WARB::BinaryError unless t1.is_a?(WARB::Value) && t1.type == WARB::ValueType.i32

          stack.push_value(WARB::ValueType.i32, t1.value < t2.value ? 1 : 0)
        }

      when 0x6A
        ->(_, stack, frame) {
          t2 = stack.pop
          raise WARB::BinaryError unless t2.is_a?(WARB::Value) && t2.type == WARB::ValueType.i32

          t1 = stack.pop
          raise WARB::BinaryError unless t1.is_a?(WARB::Value) && t1.type == WARB::ValueType.i32

          stack.push_value(WARB::ValueType.i32, t1.value + t2.value)
        }

      else
        ->(_, _, _) { raise WARB::BinaryError }
      end
    end

    class << self
      def load_int_in_memory(mod, stack, frame, type, bits, signed)
        frame.func.instructions.skip_leb128(32)
        offset = frame.func.instructions.read_u32 + stack.pop_value(WARB::ValueType.i32).value

        stack.push_value(type, mod.memory(0).load_int(offset, bits, signed))
      end

      def load_float_in_memory(mod, stack, frame, type)
        frame.func.instructions.skip_leb128(32)
        offset = frame.func.instructions.read_u32 + stack.pop_value(WARB::ValueType.i32).value

        stack.push_value(type, mod.memory(0).load_float(offset, type))
      end

      def store_int_to_memory(mod, stack, frame, type, bits)
        frame.func.instructions.skip_leb128(32)
        value = stack.pop_value(type).value
        offset = frame.func.instructions.read_u32 + stack.pop_value(WARB::ValueType.i32).value

        mod.memory(0).store_int(offset, bits, value)
      end

      def store_float_to_memory(mod, stack, frame, type)
        frame.func.instructions.skip_leb128(32)
        value = stack.pop_value(type).value
        offset = frame.func.instructions.read_u32 + stack.pop_value(WARB::ValueType.i32).value

        mod.memory(0).store_float(offset, type.bits, value)
      end
    end
  end
end
