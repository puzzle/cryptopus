# frozen_string_literal: true

class SettingSeeder
  
  def seed_text_setting(key, value)
    seed_setting(:Text, key, value)
  end

  def seed_number_setting(key, value)
    seed_setting(:Number, key, value)
  end

  def seed_true_false_setting(key, value)
    seed_setting(:TrueFalse, key, value)
  end

  def seed_setting(type, key, value)
    type.seed_once(:key) do |s|
      s.key = key
      s.value = value
    end
  end
end
