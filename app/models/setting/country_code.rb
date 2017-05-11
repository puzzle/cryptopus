# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Setting::CountryCode < Setting

  before_validation :reject_blank_values
  validate :valid_country_code
  serialize :value, Array

  private

  def valid_country_code
    value.each do |code|
      if code.present? && !/^[a-zA-Z]{2}$/.match(code)
        errors.add(:value, "invalid country code: #{code}")
      end
    end
  end

  def reject_blank_values
    value.reject!(&:blank?)
  end

end
