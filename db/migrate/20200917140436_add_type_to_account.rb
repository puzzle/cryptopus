class AddTypeAndEncryptedDataToAccount < ActiveRecord::Migration[6.0]
  def up
    add_column :accounts, :type, :string, default: 'Account::Credentials', null: false
    change_column :accounts, :type, :string, default: nil
    add_column :accounts, :encrypted_data, :text
  end

  def down
    remove_column :accounts, :type
    remove_column :accounts, :encrypted_data
  end
end
