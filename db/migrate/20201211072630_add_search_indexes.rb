class AddSearchIndexes < ActiveRecord::Migration[6.0]
  def change
    add_index :accounts, :description
    add_index :accounts, :accountname
    add_index :folders, :name
    add_index :teams, :name
  end
end
