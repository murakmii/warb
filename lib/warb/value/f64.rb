module WARB::Value
  class F64 < Primitive
    BITS = 8

    include WARB::Value::Floatize
  end
end
