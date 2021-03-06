# frozen_string_literal: true

# == Schema Information
#
# Table name: settings
#
#  id    :integer          not null, primary key
#  key   :string           not null
#  value :string
#  type  :string           not null
#


#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Setting < ApplicationRecord

  validates :key, uniqueness: true
  scope :list, (-> { all })

  class << self
    def value(key)
      setting = find_by(key: key)
      setting&.value
    end

    def policy_class
      SettingPolicy
    end
  end

end
