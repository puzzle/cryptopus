# encoding: utf-8

# == Schema Information
#
# Table name: settings
#
#  id    :integer          not null, primary key
#  key   :string           not null
#  value :string
#  type  :string           not null
#


#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Setting::TrueFalse < Setting
  def value
    self[:value] == 't'
  end

  def value=(value)
    v = value.to_s.first
    self[:value] = v
  end
end
