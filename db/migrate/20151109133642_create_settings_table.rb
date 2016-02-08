# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class CreateSettingsTable < ActiveRecord::Migration
  def up
    create_table "settings" do |t|
      t.column "key",   :string, null: false
      t.column "value", :string
      t.column "type",  :string, null: false
    end
    values = ldap_values
    create_ldap_settings(values)

    drop_table :ldapsettings
  end

  def down
    create_table "ldapsettings", :force => true do |t|
      t.column "basename",      :string, limit: 200, default: "ou=users,dc=yourdomain,dc=com", null:  false
      t.column "hostname",      :string, limit: 50,  default: "yourdomain.com",                null:  false
      t.column "portnumber",    :string, limit: 10,  default: "636",                           null:  false
      t.column "encryption",    :string, limit: 30,  default: "simple_tls",                    null:  false
      t.column "bind_dn",       :string
      t.column "bind_password", :string
    end

    Ldapsetting.create!(basename:      Setting.find_by(key: 'ldap_basename').value,
                        hostname:      Setting.find_by(key: 'ldap_hostname').value,
                        portnumber:    Setting.find_by(key: 'ldap_portnumber').value,
                        encryption:    Setting.find_by(key: 'ldap_encryption').value,
                        bind_dn:       Setting.find_by(key: 'ldap_bind_dn').value,
                        bind_password: Setting.find_by(key: 'ldap_bind_password').value)

    drop_table :settings
  end
private
  def create_ldap_settings(values)
    Setting::Text.create!(key: "ldap_basename", value: values[:basename])
    Setting::Text.create!(key: "ldap_hostname", value: values[:hostname])
    Setting::Number.create!(key: "ldap_portnumber", value: values[:portnumber])
    Setting::Text.create!(key: "ldap_encryption", value: values[:encryption])
    Setting::Text.create!(key: "ldap_bind_dn", value: values[:bind_dn])
    Setting::Text.create!(key: "ldap_bind_password", value: values[:bind_password])
    Setting::TrueFalse.create!(key: "ldap_enable", value: values[:enable])
  end

  def ldap_values
    ldapsetting = Ldapsetting.first
    ldapsetting ? ldap_values_ldap_setting(ldapsetting) : ldap_values_default
  end

  def ldap_values_ldap_setting(ldapsetting)
    values = {}
    values[:basename] = ldapsetting.basename
    values[:hostname] = ldapsetting.hostname
    values[:portnumber] = ldapsetting.portnumber
    values[:encryption] = ldapsetting.encryption
    values[:bind_dn] = ldapsetting.bind_dn
    values[:bind_password] = ldapsetting.bind_password
    values[:enable] = true
    values
  end

  def ldap_values_default
    values = {}
    values[:basename] = 'ou=users,dc=yourdomain,dc=com'
    values[:hostname] = 'yourdomain.com'
    values[:portnumber] = '636'
    values[:encryption] = 'simple_tls'
    values[:bind_dn] = ''
    values[:bind_password] = ''
    values[:enable] = false
    values
  end

  class Ldapsetting < ActiveRecord::Base
  end
end
