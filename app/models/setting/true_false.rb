class Setting::TrueFalse < Setting
  def value
    read_attribute(:value) == 't'
  end

  def value=(value)
    v = value.to_s.first
    write_attribute(:value, v)
  end
end