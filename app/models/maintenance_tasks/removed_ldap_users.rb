# encoding: utf-8

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
      raise 'Only admins can run this Task' unless executer.admin?

      if ldap_connection.test_connection
        @removed_ldap_users = collect_removed_ldap_users
      else
        raise I18n.t('flashes.admin.maintenance_tasks.ldap_connection.failed')
      end
    end
  end

  def enabled?
    Setting.find_by(key: 'ldap_enable').value
  end

  private

  def collect_removed_ldap_users
    User.ldap.collect do |user|
      user unless ldap_connection.exists?(user.username)
    end.compact
  end

  def ldap_connection
    LdapConnection.new
  end
end
