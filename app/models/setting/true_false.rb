# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Setting::TrueFalse < Setting
  def value
    read_attribute(:value) == 't'
  end

  def value=(value)
    v = value.to_s.first
    write_attribute(:value, v)
  end
end