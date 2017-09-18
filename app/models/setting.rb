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

class Setting < ApplicationRecord

  validates :key, uniqueness: true

  class << self
    def value(prefix, key)
      key = "#{prefix}_#{key}" if prefix.present?
      setting = find_by(key: key)
      if setting
        setting.value
      end
    end
  end
end
