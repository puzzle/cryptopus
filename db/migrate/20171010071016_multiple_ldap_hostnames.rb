# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class MultipleLdapHostnames < ActiveRecord::Migration[5.1]

  def up
    value = hostname
    ldap_hostname_setting.destroy!
    Setting.create!(key: 'ldap_hostname', value: [value], type: 'Setting::HostList')
  end


  def down
    value = hostname.try(:first)
    ldap_hostname_setting.destroy!
    Setting.create!(key: 'ldap_hostname', value: value, type: 'Setting::Text')
  end

  private

  def ldap_hostname_setting
    Setting.find_by(key: 'ldap_hostname')
  end

  def hostname
    ldap_hostname_setting.value
  end

end
