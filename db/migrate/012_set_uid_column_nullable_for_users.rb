class SetUidColumnNullableForUsers < ActiveRecord::Migration
  def self.up
    change_column :users, :uid, :integer, :null => true
  end

  def self.down
    change_column :users, :uid, :integer, :null => false
  end
end
