# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Authentication::SourceIpChecker
  require 'geoip'
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
    private_ip? || ip_whitelisted? || country_authorized?
  end

  def previously_authorized?(authorized_ip)
    authorized_ip == remote_ip if authorized_ip.present?
  end

  private

  attr_accessor :remote_ip, :authorized_ip

  def ip_whitelisted?
    ip = IPAddr.new(remote_ip)

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
    country_code = geo_ip.country(remote_ip).country_code2
    return false if country_code.nil? || country_code.eql?('--')
    whitelisted_country_codes.include?(country_code)
  end

  def whitelisted_country_codes
    @country_codes ||= Setting.value(:general, :country_source_whitelist)
  end

  def private_ip?
    ip = IPAddr.new(remote_ip)
    self.class.private_ip_ranges.any? { |range| range.include?(ip) }
  end

  def geo_ip
    geo_dat_file_path = Rails.root.join('db', 'GeoIP.dat')
    unless File.exist?(geo_dat_file_path)
      raise 'geo ip data file missing: please run rake geo:fetch'
    end
    GeoIP.new(geo_dat_file_path)
  end
end
