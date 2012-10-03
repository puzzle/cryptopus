class RemoveTeamAdmin < ActiveRecord::Migration
  def self.up
    remove_column "teammembers", "team_admin"
  end

  def self.down
    add_column "teammembers", "team_admin", :boolean, :default => false, :null => false
  end
end
