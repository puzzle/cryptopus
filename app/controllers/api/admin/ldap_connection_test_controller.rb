# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::LdapConnectionTestController < ApiController

  def new
    if hostlist.present?
      hostlist.each do |hostname|
        message(hostname)
      end
    else
      add_error(t('flashes.api.admin.settings.test_ldap_connection.no_hostname_present'))
    end
    render_json ''
  end

  private

  def message(hostname)
    ldap_connection.test_connection(hostname)
    add_info(t('flashes.api.admin.settings.test_ldap_connection.successful', hostname: hostname))
  rescue
    add_error(t('flashes.api.admin.settings.test_ldap_connection.failed', hostname: hostname))
  end

  def ldap_connection
    LdapConnection.new
  end

  def hostlist
    Setting.value(:ldap, 'hostname')
  end

end
