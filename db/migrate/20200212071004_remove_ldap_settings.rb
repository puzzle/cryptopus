class RemoveLdapSettings < ActiveRecord::Migration[6.0]
  def up
    LdapConnection::LDAP_SETTING_KEYS.each do |s|
      destroy_ldap_setting(s)
    end
    destroy_ldap_setting(:enable)
    destroy_ldap_setting(:encryption)
  end

  private
  
  def destroy_ldap_setting(key)
    Setting.find_by(key: "ldap_#{key}").try(:destroy)
  end
end
