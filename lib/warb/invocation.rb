module WARB
  class Invocation
    def initialize(mod, func)
      @mod = mod
      @func = func
      @stack = WARB::Stack.new
    end

    def execute(*vars)
      vars.each {|v| @stack.push(v) }

      @stack.push_new_frame(@func, @mod)

      ret =
        loop do
          instr = @stack.current_frame.func.body.advance
          WARB::Instructions.execute(@stack, instr)

          break @stack.to_a.dup if @stack.current_frame.nil?
        end

      @stack.reset
      ret
    end
  end
end
