module WARB::Value
  class I64 < Primitive
    BITS = 64

    include WARB::Value::Integerize
  end
end
