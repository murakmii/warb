module WARB
  class Invocation
    def initialize(mod, func)
      @mod = mod
      @func = func
      @stack = WARB::Stack.new
    end

    def execute(*args)
      args.each_slice(2) do |(type, value)|
        @stack.push_value(type, value)
      end

      @stack.push_new_frame(@func)
      @stack.push_label(@func.blocks[0])

      ret =
        loop do
          instr = @stack.current_frame.func.instructions.advance
          WARB::Instructions::MAP[instr].call(@mod, @stack, @stack.current_frame)

          if @stack.frames == 1 && @stack.current_frame.func.instructions.eof?
            @stack.pop_current_frame
            break @stack.to_a.first
          end
        end

      @stack.reset
      ret
    end
  end
end
