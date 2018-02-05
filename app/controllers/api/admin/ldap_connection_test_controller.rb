# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class Api::Admin::LdapConnectionTestController < ApiController
  helper_method :ldap_enabled

  def new
    return 404 unless ldap_enabled
    
    hostname_error unless LdapConnection.connect.any

    render_json ''
  end

  private

  def ldap_enabled
    Setting.value(:ldap, 'enable')
  end

  def hostname_error
    add_error(t('flashes.api.admin.settings.test_ldap_connection.no_hostname_present'))
  end
end
