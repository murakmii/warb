module WasmMachine
  class Frame
    attr_reader :func, :local_vars

    def initialize(func, args)
      @func = func
      @local_vars = args + func.locals.map(&:zero_value)
      @saved_pc = nil
    end

    def on_activated
      if @saved_pc
        @func.instructions.pos = @saved_pc
        @saved_pc = nil
      end
    end

    def on_deactivated
      @saved_pc = @func.instructions.pos
    end

    def jump_to_end_of_block(block)
      @func.instructions.pos = block.end_index + 1
    end

    def jump_to_continuation_of_block(block)
      if block.is_a?(WasmMachine::ControlFlow::Loop)
        @func.instructions.pos = block.before_block_index
      else
        @func.instructions.pos = block.end_index + 1
      end
    end
  end
end
