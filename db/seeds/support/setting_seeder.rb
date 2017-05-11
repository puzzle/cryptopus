# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class SettingSeeder
  
  def seed_text_setting(key, value, order)
    seed_setting(:Text, key, value, order)
  end

  def seed_number_setting(key, value, order)
    seed_setting(:Number, key, value, order)
  end

  def seed_true_false_setting(key, value, order)
    seed_setting(:TrueFalse, key, value, order)
  end

  def seed_setting(type, key, value, order)
    "Setting::#{type}".constantize.seed_once(:key) do |s|
      s.key = key
      s.value = value
      s.order = order
    end
  end
end
