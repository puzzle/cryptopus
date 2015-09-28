class AddNoRootFlagToTeams < ActiveRecord::Migration
  def self.up
    add_column "teams", "noroot", :boolean, :default => 0, :null => false
    
    Team.reset_column_information
    Team.all.each do |team|
      team.noroot = false
      team.save
    end
    
  end

  def self.down
    remove_column "teams", "noroot"
  end
end
