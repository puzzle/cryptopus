# frozen_string_literal: true

class RenameAccountsToEncryptables < ActiveRecord::Migration[6.1]
  def up
    rename_table :accounts, :encryptables

    execute "UPDATE encryptables SET type = 'Encryptable::Credentials' WHERE type = 'Account::Credentials'"
    execute "UPDATE encryptables SET type = 'Encryptable::OSESecret' WHERE type = 'Account::OSESecret'"
  end

  def down
    execute "UPDATE encryptables SET type = 'Account::Credentials' WHERE type = 'Encryptable::Credentials'"
    execute "UPDATE encryptables SET type = 'Account::OSESecret' WHERE type = 'Encryptable::OSESecret'"

    rename_table :encryptables, :accounts
  end
end
