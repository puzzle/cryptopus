# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::LdapConnectionTestController < ApiController

  before_action :authorize_action

  # /api/admin/ldap_connection_test/new
  def new
    if ldap_enabled
      begin
        test_ldap
      rescue ArgumentError
        hostlist_error
      end
      render_json ''
    else
      render status: :not_found, json: {}
    end
  end

  private

  def authorize_action
    authorize Setting, :ldap_connection_test?
  end

  def test_ldap
    ldap = LdapConnection.new
    hosts = ldap.test
    hosts_status_messages(hosts)
  end

  def ldap_enabled
    Setting.value(:ldap, 'enable')
  end

  def hosts_status_messages(hosts)
    hosts[:success].each do |host|
      hostname_info(host)
    end

    hosts[:failed].each do |host|
      hostname_error(host)
    end
  end

  def hostlist_error
    add_error(t('flashes.api.admin.settings.test_ldap_connection.no_hostname_present'))
  end

  def hostname_info(hostname)
    add_info(t('flashes.api.admin.settings.test_ldap_connection.successful', hostname: hostname))
  end

  def hostname_error(hostname)
    add_error(t('flashes.api.admin.settings.test_ldap_connection.failed', hostname: hostname))
  end
end
