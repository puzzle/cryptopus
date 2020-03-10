# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 33 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MaintenanceTasks::RemovedLdapUsers < MaintenanceTask

  attr_reader :removed_ldap_users

  self.id = 3
  self.label = 'Removed ldap users'
  self.description = 'Lists the ldap users which have been removed.'

  def execute
    super do
      raise 'Only admins can run this Task' unless executer.admin? || executer.conf_admin?

      connection_error = I18n.t('flashes.admin.maintenance_tasks.ldap_connection.failed')
      raise connection_error unless ldap_connection.test_connection

      @removed_ldap_users = collect_removed_ldap_users
    end
  end

  def enabled?
    AuthConfig.ldap_enabled?
  end

  private

  def collect_removed_ldap_users
    User::Human.ldap.reject do |user|
      ldap_connection.all_uids.include?(user.username)
    end
  end

  def ldap_connection
    @ldap_connection ||= LdapConnection.new
  end
end
