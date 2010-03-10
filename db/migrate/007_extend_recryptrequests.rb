class ExtendRecryptrequests < ActiveRecord::Migration

  def self.up
    add_column "recryptrequests", "adminrequired", :boolean, :default => 1, :null => false
    add_column "recryptrequests", "rootrequired", :boolean, :default => 1, :null => false

    add_column "teammembers", "locked", :boolean, :default => 0, :null => false
  end

  def self.down
    remove_column "recryptrequest", "adminrequired"
    remove_column "recryptrequest", "rootrequired"

    remove_column "teammembers", "locked"
  end

end
