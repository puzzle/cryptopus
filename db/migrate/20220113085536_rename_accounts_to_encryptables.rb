# frozen_string_literal: true

class RenameAccountsToEncryptables < ActiveRecord::Migration[6.1]
  def up
    rename_table :accounts, :encryptables
  end

  def down
    rename_table :encryptables, :accounts
  end
end
