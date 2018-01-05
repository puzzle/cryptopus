# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

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
    "Setting::#{type}".constantize.seed_once(:key) do |s|
      s.key = key
      s.value = value
    end
  end
end
