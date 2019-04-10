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

    def current_frame
      @frame_indexes.last ? @stack[@frame_indexes.last] : nil
    end

    def no_label_on_current_frame?
      current_frame && current_frame.labels.empty?
    end

    def frame_on_top?
      @stack.size - 1 == @frame_indexes.last
    end

    def frames
      @frame_indexes.size
    end

    def pop
      @stack.pop
    end

    def pop_value(type)
      raise WARB::BinaryError unless peek.is_a?(WARB::Value) && peek.type == type
      pop
    end

    def pop_values(types)
      return EMPTY_ARRAY if types.empty?

      count = types.size
      values = Array.new(count)

      (count - 1).downto(0).each {|i| values[i] = pop_value(types[i]) }
      values
    end

    def pop_label(nth)
      raise WARB::BinaryError if current_frame.nil? || nth >= current_frame.labels.size

      index = current_frame.labels[-(nth + 1)]
      label = @stack[index]

      returned = pop_values(label.block.return_types)

      @stack.slice!(index..-1)
      current_frame.labels.slice!(-(nth + 1)..-1)
      @stack.concat(returned) if returned.any?

      label.block
    end

    def pop_current_frame
      raise WARB::BinaryError unless current_frame

      returned = pop_values(current_frame.func.type.return_types)

      raise WARB::BinaryError unless frame_on_top?

      @stack.pop
      @frame_indexes.pop
      @stack.concat(returned) if returned.any?

      current_frame&.on_activated
    end

    def pop_inner_most_label
      index = current_frame&.labels&.pop
      index ? @stack.delete_at(index).block : raise(WARB::BinaryError)
    end

    def peek(index = -1)
      @stack[index]
    end

    def push(e)
      @stack.push(e)
    end

    def push_value(type, value)
      @stack << WARB::Value.new(type, value)
    end

    def push_label(block)
      @stack << WARB::Label.new(block)
      current_frame.labels << (@stack.size - 1)
    end

    def push_new_frame(func)
      args = Array.new(func.type.param_types.size)
      (args.size - 1).downto(0) do |i|
        args[i] = pop_value(func.type.param_types[i])
      end

      frame = WARB::Frame.new(func, args)

      current_frame&.on_deactivated
      func.instructions.rewind
      frame.on_activated

      @stack << frame
      @frame_indexes << (@stack.size - 1)
    end
  end
end
