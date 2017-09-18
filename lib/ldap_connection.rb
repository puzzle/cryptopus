# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'net/ldap'

class LdapConnection

  MANDATORY_LDAP_SETTING_KEYS = %i[hostname portnumber basename].freeze
  LDAP_SETTING_KEYS = (MANDATORY_LDAP_SETTING_KEYS + %i[bind_dn bind_password]).freeze

  def initialize
    collect_settings
    assert_setting_values
  end

  def login(username, password)
    return false unless username.present? && password.present?
    return false unless username_valid?(username)
    result = connection.bind_as(base: settings[:basename],
                                filter: "uid=#{username}",
                                password: password)
    if result
      ldap = connection(method: :simple, username: result.first.dn, password: password)
      return true if ldap.bind
    end
    false
  end

  def ldap_info(uidnumber, attribute)
    raise ArgumentError unless uidnumber.present? && attribute.present?
    filter = Net::LDAP::Filter.eq('uidnumber', uidnumber.to_s)
    result = connection.search(base: settings[:basename],
                               filter: filter).try(:first).try(attribute).try(:first)
    result.present? ? result : "No #{attribute} for uidnumber #{uidnumber}"
  end

  def uidnumber_by_username(username)
    return unless username_valid?(username)
    filter = Net::LDAP::Filter.eq('uid', username)
    connection.search(base: settings[:basename],
                      filter: filter,
                      attributes: ['uidnumber']) do |entry|
                        return entry.uidnumber[0].to_s if entry.respond_to?(:uidnumber)
                      end
    raise "No uidnumber for uid #{username}"
  end

  private

  attr_reader :settings

  def collect_settings
    @settings = {}
    LDAP_SETTING_KEYS.each do |k|
      @settings[k] = Setting.value(:ldap, k)
    end
  end

  def assert_setting_values
    MANDATORY_LDAP_SETTING_KEYS.each do |k|
      raise ArgumentError, "missing config field: #{k}" if settings[k].blank?
    end
  end

  def username_valid?(username)
    username =~ /^[a-zA-Z\d]+$/
  end

  def connection(options = {})
    settings[:hostname].each do |host|
      params = { host: host, port: settings[:portnumber], encryption: :simple_tls }
      params.merge(options)
      ldap = connect(params)
      return ldap if ldap.present?
    end
  end

  def connect(params)
    ldap = Net::LDAP.new(params)
    ldap.bind
    ldap
  rescue
    nil
  end

end
