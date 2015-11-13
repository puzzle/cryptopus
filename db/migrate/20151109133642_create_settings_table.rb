class CreateSettingsTable < ActiveRecord::Migration
  def up
    create_table "settings" do |t|
      t.column "key",   :string, null:  false
      t.column "value", :string
      t.column "type",  :string, null:  false
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
    ldapsettings = Ldapsetting.first
    ldapsettings ? ldap_values_ldap_settings(ldapsettings) : ldap_values_default
  end

  def ldap_values_ldap_settings(ldapsettings)
    values = {}
    values[:basename] = ldapsettings.basename
    values[:hostname] = ldapsettings.hostname
    values[:portnumber] = ldapsettings.portnumber
    values[:encryption] = ldapsettings.encryption
    values[:bind_dn] = ldapsettings.bind_dn
    values[:bind_password] = ldapsettings.bind_password
    values[:enable] = ldapsettings.encryption
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
    values[:enable] = 't'
    values
  end

  class Ldapsetting < ActiveRecord::Base
  end
end
