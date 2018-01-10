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
    return false if user_invalid?(username, password)
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

  def exists?(username)
    return unless username_valid?(username)

    filter = Net::LDAP::Filter.eq('uid', username)
    result = connection.search(base: settings[:basename],
                               filter: filter)
    result.present?
  end

  def test_connection
    connection.bind
  rescue
    false
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

  def user_invalid?(username, password)
    true unless username.present? &&
      password.present? &&
      username_valid?(username)
  end

  def username_valid?(username)
    username =~ /^[a-zA-Z\d]+$/
  end

  def connection(options = {})
    if @ldap_host
      params = connection_params(@ldap_host, options)
      Net::LDAP.new(params)
    else
      hosts_connection(options)
    end
  end

  def hosts_connection(options)
    ldap_hosts.each do |host|
      @ldap_host = host
      params = connection_params(host, options)
      begin
        return ldap_connection(params)
      rescue Net::LDAP::Error => e
        handle_exception(host, e)
      end
    end
  end

  def ldap_connection(params)
    ldap = Net::LDAP.new(params)
    ldap.bind
    ldap
  end

  def handle_exception(host, e)
    if ldap_hosts.last == host
      raise e
    else
      return if e.is_a?(Net::LDAP::ConnectionRefusedError)
      raise(e) unless expected_message(e.message)
    end
  end

  def connection_params(host, options)
    params = { host: host, port: settings[:portnumber], encryption: :simple_tls }
    params.merge(options)
  end

  def ldap_hosts
    settings[:hostname]
  end

  def expected_message(message)
    message =~ /name or service not known/i ||
      /connection timed out/i
  end

end
