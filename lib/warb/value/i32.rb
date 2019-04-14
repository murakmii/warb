module WARB::Value
  class I32 < Primitive
    BITS = 32

    include WARB::Value::Integerize
  end
end
