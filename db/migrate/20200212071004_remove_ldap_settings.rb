class RemoveLdapSettings < ActiveRecord::Migration[6.0]

  LDAP_SETTING_KEYS = %i[hostname portnumber basename bind_dn bind_password enable encryption].freeze

  def up
    rename_column :settings, :type, :not_type

    LDAP_SETTING_KEYS.each do |key|
      Setting.find_by(key: "ldap_#{key}").try(:destroy)
    end

    rename_column :settings, :not_type, :type
  end
end
