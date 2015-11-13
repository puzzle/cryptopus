class Setting::TrueFalse < Setting
  def value
    read_attribute(:value) == 't'
  end
end