module WasmMachine
  class Stack
    def initialize
      @stack = []
      @frame_indexes = []
    end

    def reset
      @stack.clear
      @frame_indexes.clear
    end

    def to_a
      @stack
    end

    def current_frame
      @frame_indexes.last ? @stack[@frame_indexes.last] : nil
    end

    def frames
      @frame_indexes.size
    end

    def pop
      @stack.pop
    end

    def pop_label(nth)
      index = find_nth_label_index(nth)
      raise WasmMachine::BinaryError unless index

      label = @stack[index]
      value = nil
      if label.block.arity
        value = pop
        raise WasmMachine::BinaryError unless value.is_a?(WasmMachine::Value) && value.type == label.block.arity
      end

      @stack.slice!(index..-1)
      @stack.push(value) if value

      label.block
    end

    def pop_current_frame
      raise WasmMachine::BinaryError unless current_frame

      return_value = nil
      if current_frame.func.type.return_type
        raise WasmMachine::BinaryError unless peek.is_a?(WasmMachine::Value) && peek.type == current_frame.func.type.return_type
        return_value = pop
      end

      raise WasmMachine::BinaryError unless @frame_indexes.last == (@stack.size - 1)

      @stack.pop
      @frame_indexes.pop
      @stack << return_value if return_value

      current_frame&.on_activated
    end

    def delete_inner_most_label
      index = find_nth_label_index(0)
      index ? @stack.delete_at(index).block : nil
    end

    def peek(index = -1)
      @stack[index]
    end

    def push(e)
      @stack.push(e)
    end

    def push_value(type, value)
      @stack << WasmMachine::Value.new(type, value)
    end

    def push_label(block)
      @stack << WasmMachine::Label.new(block)
    end

    def push_new_frame(func)
      args = Array.new(func.type.param_types.size)
      func.type.param_types.each.with_index do |t, i|
        arg = pop
        raise WasmMachine::BinaryError unless arg.type == t
        args[i] = arg
      end

      frame = WasmMachine::Frame.new(func, args)

      current_frame&.on_deactivated
      func.instructions.rewind
      frame.on_activated

      @stack << frame
      @frame_indexes << (@stack.size - 1)
    end

    def find_nth_label_index(nth)
      n = 0
      @stack.each_with_index.reverse_each do |e, i|
        if e.is_a?(WasmMachine::Frame)
          break nil
        elsif e.is_a?(WasmMachine::Label)
          if n == nth
            break i
          else
            n += 1
          end
        end
      end
    end
  end
end
