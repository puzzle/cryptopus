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


#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Setting::Host < Setting

  before_validation :reject_blank_values
  validate :must_be_valid_host
  serialize :value, Array

  private

  def must_be_valid_host
    value.each do |host|
      if host.present? && !/^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])$/.match(host)
        errors.add(:value, "invalid host: #{host}")
      end
    end
  end

  def reject_blank_values
    value.reject!(&:blank?)
  end
end
