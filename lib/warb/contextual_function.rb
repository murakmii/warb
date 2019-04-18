module WARB
  class ContextualFunction
    attr_reader :func

    def initialize(mod, func)
      @mod = mod
      @func = func
    end

    def invoke(*vars)
      stack = WARB::Stack.new
      vars.each {|v| stack.push(v) }

      stack.push_new_frame(@func, @mod)

      loop do
        instr = stack.current_frame.func.body.advance
        WARB::Instructions.execute(stack, instr)

        break stack.to_a.dup if stack.current_frame.nil?
      end
    end
  end
end
