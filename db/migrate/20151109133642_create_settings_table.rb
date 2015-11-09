class CreateSettingsTable < ActiveRecord::Migration
  def up
    create_table "settings" do |t|
      t.column "key",   :string, null:  false
      t.column "value", :string
      t.column "type",  :string, null:  false
    end

    ldapsettings = Ldapsetting.first
    Setting::Text.create!(key: "ldap_basename", value: ldapsettings.basename)
    Setting::Text.create!(key: "ldap_hostname", value: ldapsettings.hostname)
    Setting::Number.create!(key: "ldap_portnumber", value: ldapsettings.portnumber)
    Setting::Text.create!(key: "ldap_encryption", value: ldapsettings.encryption)
    Setting::Text.create!(key: "ldap_bind_dn", value: ldapsettings.bind_dn)
    Setting::TrueFalse.create!(key: "ldap_enable", value: true)

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

    Ldapsetting.create!(basename:      Setting.find_by(key: 'ldap_basename'),
                        hostname:      Setting.find_by(key: 'ldap_hostname'),
                        portnumber:    Setting.find_by(key: 'ldap_portnumber'),
                        encryption:    Setting.find_by(key: 'ldap_encryption'),
                        bind_dn:       Setting.find_by(key: 'ldap_bind_dn'),
                        bind_password: Setting.find_by(key: 'ldap_bind_password'))

    drop_table :settings
  end

  class Ldapsetting < ActiveRecord::Base
  end
end
