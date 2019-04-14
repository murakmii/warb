module WARB::Value::Integerize
  def initialize(value = 0)
    super(value)
  end

  def unsigned
    value
  end

  def signed
    value < (1 << (self.class::BITS - 1)) ? value : (value - (1 << self.class::BITS))
  end

  def +(int)
    replace((unsigned + int.unsigned) & (1 << self.class::BITS) - 1)
    self
  end

  def ==(int)
    value == int.unsigned
  end
end
