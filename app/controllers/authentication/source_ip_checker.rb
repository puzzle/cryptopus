# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Authentication::SourceIpChecker
  require 'geoip'


  def initialize(remote_ip)
    @remote_ip = remote_ip
  end

  def ip_authorized?
    ip_whitelisted? || country_authorized?
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
    @whitelisted_ips ||= Authentication::IpWhitelist.new.list
  end

  def country_authorized?
    country_code = geo_ip.country(remote_ip).country_code2
    return false if country_code.nil? || country_code.eql?('--')
    whitelisted_country_codes.include?(country_code)
  end

  def whitelisted_country_codes
    @country_codes ||= Setting.value(:general, :country_source_whitelist)
  end

  def geo_ip
    geo_dat_file_path = "#{Rails.root}/db/GeoIP.dat"
    unless File.exists?(geo_dat_file_path)
      raise 'geo ip data file missing: please run rake geo:fetch'
    end
    GeoIP.new(geo_dat_file_path)
  end
end
