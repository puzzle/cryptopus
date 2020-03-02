# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'net/ldap'

class LdapConnection

  MANDATORY_LDAP_SETTING_KEYS = [:hostnames, :portnumber, :basename].freeze
  LDAP_SETTING_KEYS = (MANDATORY_LDAP_SETTING_KEYS + [:bind_dn, :bind_password]).freeze

  def initialize
    validate_settings!
  end

  def authenticate!(username, password)
    return false if user_invalid?(username, password)

    user_entry = search_for_login(username)
    if user_entry
      connection.auth(user_entry.dn, password)
      return connection.bind
    end
    false
  end

  def ldap_info(uidnumber, attribute)
    raise ArgumentError unless uidnumber.present? && attribute.present?

    filter = Net::LDAP::Filter.eq('uidnumber', uidnumber.to_s)
    result = connection.search(base: settings[:basename],
                               filter: filter).try(:first).try(attribute).try(:first)
    result.presence || "No #{attribute} for uidnumber #{uidnumber}"
  end

  def uidnumber_by_username(username)
    return unless username_valid?(username)

    filter = Net::LDAP::Filter.eq('uid', username)
    connection.search(base: basename,
                      filter: filter,
                      attributes: ['uidnumber']) do |entry|
                        return entry.uidnumber[0].to_s if entry.respond_to?(:uidnumber)
                      end
    raise "No uidnumber for uid #{username}"
  end

  def exists?(username)
    return unless username_valid?(username)

    filter = Net::LDAP::Filter.eq('uid', username)
    result = connection.search(base: basename,
                               filter: filter)
    result.present?
  end

  def test
    success = []
    failed = []

    ldap_hosts.each do |host|
      reachable?(host) ? success << host : failed << host
    end

    { success: success, failed: failed }
  end

  def test_connection
    connection.bind
  rescue StandardError
    false
  end

  private

  def reachable?(host)
    params = connection_params(host)
    ldap = ldap_connection(params, false)
    ldap.bind
  rescue StandardError
    false
  end

  def user_invalid?(username, password)
    true unless username.present? &&
      password.present? &&
      username_valid?(username)
  end

  def username_valid?(username)
    username =~ /^[a-zA-Z\d]+$/
  end

  def connection
    @connection ||= first_available_server
  end

  def first_available_server
    ldap_hosts.each do |host|
      params = connection_params(host)
      begin
        return ldap_connection(params)
      rescue Net::LDAP::Error => e
        handle_exception(host, e)
      end
    end
  end

  def ldap_connection(params, bind = true)
    ldap = Net::LDAP.new(params)
    if bind_dn.present?
      ldap.auth(bind_dn, bind_password)
    end
    ldap.bind if bind
    ldap
  end

  def handle_exception(host, exception)
    if ldap_hosts.last == host
      raise exception
    else
      return if exception.is_a?(Net::LDAP::ConnectionRefusedError)
      raise(exception) unless expected_message(exception.message)
    end
  end

  def connection_params(host)
    { host: host, port: settings[:portnumber], encryption: settings[:encryption] }
  end

  def ldap_hosts
    settings[:hostnames]
  end

  def bind_dn
    settings[:bind_dn]
  end

  def bind_password
    settings[:bind_password]
  end

  def basename
    settings[:basename]
  end

  def expected_message(message)
    message =~ /name or service not known|connection timed out/i
  end

  def settings
    @settings ||= load_settings
  end

  def load_settings
    ldap_settings = AuthConfig.ldap_settings
    raise ArgumentError, 'No ldap settings' if ldap_settings.blank?

    encryptions = { 'simple_tls' => :simple_tls, 'start_tls' => :start_tls }
    ldap_settings[:encryption] = encryptions[ldap_settings[:encryption]] || :simple_tls
    password = ldap_settings[:bind_password]
    ldap_settings[:bind_password] = Base64.decode64(password) if password.present?
    ldap_settings
  end

  def validate_settings!
    MANDATORY_LDAP_SETTING_KEYS.each do |k|
      raise ArgumentError, "missing config field: #{k}" if settings[k].blank?
    end
  end

  def search_for_login(username)
    filter = Net::LDAP::Filter.eq('uid', username)
    ldap_entry = nil
    connection.search(base: basename, filter: filter) { |entry| ldap_entry = entry }
    ldap_entry
  end
end
