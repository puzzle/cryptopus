# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Setting::IpRange < Setting
  require 'ipaddr'

  before_validation :reject_blank_values
  validate :must_be_valid_ips
  serialize :value, Array

  private

  def must_be_valid_ips
    value.each do |ip|
      begin
        IPAddr.new(ip)
      rescue IPAddr::InvalidAddressError
        errors.add(:value, "invalid ip address: #{ip}")
        break
      end
    end
  end

  def reject_blank_values
    value.reject!(&:blank?)
  end
end
