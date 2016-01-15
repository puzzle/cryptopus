class RemoveTeammemberAdmin < ActiveRecord::Migration
  def self.up
    remove_column "teammembers", "admin"
  end

  def self.down
    add_column "teammembers", "admin", :boolean, :default => false, :null => false
  end
end
