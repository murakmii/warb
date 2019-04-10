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
      @stack.push_label(@func.blocks.root)

      ret =
        loop do
          instr = @stack.current_frame.func.instructions.advance
          WARB::Instructions::MAP[instr].call(@mod, @stack, @stack.current_frame)

          break @stack.to_a.dup if @stack.current_frame.nil?
        end

      @stack.reset
      ret
    end
  end
end
