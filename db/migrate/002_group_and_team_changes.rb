class GroupAndTeamChanges < ActiveRecord::Migration
  def self.up
  
    # Grouppasswords => Teammembers table  
    rename_table  "grouppasswords", "teammembers"
    rename_column "teammembers",   "group_id", "team_id"
    add_column    "teammembers",   "team_admin", :boolean, :default => 0, :null => false

    # Change the name from groups to teams
    rename_table  "groups", "teams"
    rename_column "teams",  "groupname", "name"
    add_column    "teams",  "visible",   :boolean, :default => true, :null => false
    add_column    "teams",  "private",   :boolean, :default => false, :null => false
    Team.find(:all).each do |team|
      teammember = Teammember.find(:first, :conditions => ["user_id = ? and team_id = ?", team.user_id, team.id])
      teammember.team_admin = true
      teammember.save
    end
    remove_column "teams",  "user_id"
  
    # Add the new admin flag to the users table
    add_column "users", "admin", :boolean, :default => false, :null => false
    
    # this is our new group table
    create_table "groups", :force => true do |t|
      t.column "name",   :string,    :limit => 40, :default => "", :null => false
      t.column "description", :text
      t.column "created_on",  :timestamp,                               :null => false
      t.column "updated_on",  :timestamp,                               :null => false
      t.column "team_id",     :integer,                 :default => 0,  :null => false
    end
    
    # create a default group for every team with accounts
    Team.find(:all).each do |team|
      group = Group.new()
      group.name = "Default"
      group.description = "Default group, created for migration"
      group.team_id = team.id
      group.save
      
      # Accounts are now linked to their groups and not directly to the team
      Account.find(:all, :conditions => ["group_id = ?", team.id]).each do |account|
        account.group_id = group.id
        account.save
      end
    end
    
  end

  def self.down
    
    # link accounts back to the team table
    Group.find(:all).each do |group|
      Account.find(:all, :conditions => ["group_id = ?", group.id]).each do |account|
        account.group_id = group.team_id
        account.save
      end
    end
    drop_table :groups
    
    # remove the admin flag from the users table
    remove_column "users", "admin"
    
    # Change the name from teams to groups
    add_column "teams",  "user_id", :integer, :default => 0, :null => false
    Teammember.find(:all, :conditions => ["team_admin = ?", true]).each do |teammember|
        team = Team.find(teammember.team_id)
        team.user_id = teammember.user_id
        team.save
    end
    rename_table  "teams",  "groups"
    rename_column "groups", "name", "groupname"
    remove_column "groups", "visible"
    remove_column "groups", "private"
    
    # Teammembers => Grouppasswords table 
    rename_table  "teammembers",    "grouppasswords"
    rename_column "grouppasswords", "team_id", "group_id"
    remove_column "grouppasswords", "team_admin"
    
  end
end
