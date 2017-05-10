# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Setting < ActiveRecord::Base

  validates_uniqueness_of :key

  scope :by_section, lambda { |prefix|
    Setting.where('key LIKE :prefix', { prefix: "#{prefix}_%" })
      .order(order: :asc)
  }

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
