class AddTagToAccounts < ActiveRecord::Migration[5.1]
  def change
    add_column :accounts, :tag, :string
    add_index :accounts, :tag
  end
end
