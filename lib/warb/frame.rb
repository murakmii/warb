module WARB
  class Frame
    attr_reader :mod, :func, :labels, :local_vars

    def initialize(mod, func, args)
      @mod = mod
      @func = func
      @labels = []
      @local_vars = args + func.locals.map(&:new)
      @saved_pc = nil
    end

    def on_activated
      if @saved_pc
        @func.body.pos = @saved_pc
        @saved_pc = nil
      end
    end

    def on_deactivated
      @saved_pc = @func.body.pc
    end

    def pc
      @func.body.pc
    end

    def jump_to(pc)
      @func.body.pos = pc
    end

    def no_label?
      @labels.empty?
    end

    def get_local_var(index)
      assert_valid_local_var_index(index)
      @local_vars[index].clone
    end

    def set_local_var(index, var)
      assert_valid_local_var_index(index)

      raise WARB::BinaryError unless @local_vars[index].class == var.class
      @local_vars[index] = var
    end

    private

      def assert_valid_local_var_index(index)
        raise WARB::BinaryError if index < 0 || index >= @local_vars.size
      end
  end
end
