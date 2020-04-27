class RenameLdapuidToProvideruid < ActiveRecord::Migration[6.0]
  def up
    change_column :users, :ldap_uid, :string
    rename_column :users, :ldap_uid, :provider_uid
  end

  def down
    change_column :users, :provider_uid, :integer
    rename_column :users, :provider_uid, :ldap_uid
  end
end
