module WARB
  class Stack
    EMPTY_ARRAY = [].freeze

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

    def f
      current_frame
    end

    def current_frame
      @frame_indexes.last ? @stack[@frame_indexes.last] : nil
    end

    def frame_on_top?
      @stack.size - 1 == @frame_indexes.last
    end

    def pop
      @stack.pop
    end

    def pop_value(type)
      raise WARB::BinaryError unless peek.is_a?(type)
      pop
    end

    def pop_values(types)
      return EMPTY_ARRAY if types.empty?

      count = types.size
      values = Array.new(count)

      (count - 1).downto(0).each {|i| values[i] = pop_value(types[i]) }
      values
    end

    def pop_any_value
      raise WARB::BinaryError unless peek.is_a?(WARB::Value::Primitive)
      pop
    end

    def pop_i32
      pop_value(WARB::Value::I32).value
    end

    def return_current_frame
      returned = pop_values(current_frame.func.type.return_arity)

      @stack.slice!(@frame_indexes.pop..-1)
      @stack.concat(returned) if returned.any?

      current_frame&.on_activated
    end

    # @param [Integer] label_index
    def break_label(label_index)
      raise WARB::BinaryError if current_frame.nil? || label_index >= current_frame.labels.size

      index = current_frame.labels[-(label_index + 1)]
      block = @stack[index]

      returned = pop_values(block.arity)

      @stack.slice!(index..-1)
      current_frame.labels.slice!(-(label_index + 1)..-1)
      @stack.concat(returned) if returned.any?

      block
    end

    def exit_current_frame
      returned = pop_values(current_frame.func.type.return_arity)

      raise WARB::BinaryError unless frame_on_top?

      @stack.pop
      @frame_indexes.pop
      @stack.concat(returned) if returned.any?

      current_frame&.on_activated
    end

    # @return [WARB::Structured::Block]
    def exit_label
      index = current_frame.labels.pop
      index ? @stack.delete_at(index) : raise(WARB::BinaryError)
    end

    def peek
      @stack.last
    end

    def peek_value(type)
      raise WARB::BinaryError unless @stack.last.is_a?(WARB::Value) && @stack.last.type == type
      @stack.last.value
    end

    def push(e)
      @stack.push(e)
    end

    def push_label(block)
      @stack << block
      current_frame.labels << (@stack.size - 1)
    end

    def push_new_frame(func, mod)
      frame = WARB::Frame.new(current_frame&.mod || mod, func, pop_values(func.type.arity))

      current_frame&.on_deactivated
      func.body.rewind
      frame.on_activated

      @stack << frame
      @frame_indexes << (@stack.size - 1)

      push_label(func.blocks.root)
    end
  end
end
