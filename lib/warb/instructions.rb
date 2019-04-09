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
          popped_block = stack.delete_inner_most_label
          if popped_block
            frame.jump_to_end_of_block(popped_block)
          else
            stack.pop_current_frame
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
  end
end
