module WARB::Structured
  class IfElse < Block
    attr_reader :else_start_pc

    # @return [Boolean]
    def exists_else?
      !!@else_start_pc
    end

    # @param [Integer] pc
    def set_else_start_pc(pc)
      @else_start_pc = pc
    end
  end
end
