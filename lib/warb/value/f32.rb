module WARB::Value
  class F32 < Primitive
    BYTES = 4

    include WARB::Value::Floatize
  end
end
