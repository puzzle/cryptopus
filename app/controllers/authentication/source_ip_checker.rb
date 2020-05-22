# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Authentication::SourceIpChecker
  require 'maxmind/db'
  require 'ipaddr'

  PRIVATE_IP_RANGES = ['10.0.0.0/8', '127.0.0.0/8',
                       '172.16.0.0/12', '192.168.0.0/16',
                       '::1'].freeze

  def self.private_ip_ranges
    @private_ip_ranges ||= PRIVATE_IP_RANGES.collect do |r|
      IPAddr.new(r)
    end
  end

  def initialize(remote_ip)
    @remote_ip = remote_ip
  end

  def ip_authorized?
    private_ip? || ip_whitelisted? || GeoIp.activated? && country_authorized?
  end

  def root_ip_authorized?
    private_ip?
  end

  def previously_authorized?(authorized_ip)
    authorized_ip == remote_ip if authorized_ip.present?
  end

  private

  attr_accessor :remote_ip, :authorized_ip

  def ip_whitelisted?
    ip = IPAddr.new(remote_ip)
    return true unless GeoIp.activated? || collect_whitelisted_ips.any?

    whitelisted_ips.any? { |i| i.include?(ip) }
  end

  def whitelisted_ips
    @whitelisted_ips ||= collect_whitelisted_ips
  end

  def collect_whitelisted_ips
    Setting.value('general', 'ip_whitelist').collect do |i|
      IPAddr.new(i)
    end
  end

  def country_authorized?
    country_code = geo_ip.country_code(remote_ip)
    country_code.present? &&
      whitelisted_country_codes.include?(country_code)
  end

  def whitelisted_country_codes
    @whitelisted_country_codes ||= Setting.value(:general, :country_source_whitelist)
  end

  def private_ip?
    ip = IPAddr.new(remote_ip)
    self.class.private_ip_ranges.any? { |range| range.include?(ip) }
  end

  def geo_ip
    @geo_ip ||= GeoIp.new
  end
end
