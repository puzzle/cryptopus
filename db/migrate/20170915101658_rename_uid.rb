class RenameUid < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :uid, :ldap_uid
  end
end
