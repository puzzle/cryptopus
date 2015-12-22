class AddAdminFlagToTeammembers < ActiveRecord::Migration
  def self.up
    add_column "teammembers", "admin", :boolean, :default => 0, :null => false

    root = User.unscoped.find_by_uid( "0" )

    unless root.nil?
      Teammember.reset_column_information
      teammembers = Teammember.find_all_by_user_id(root.id)

      teammembers.each do |teammember|
        teammember.admin = true
        teammember.save
      end
    end

  end

  def self.down
    remove_column "teammembers", "admin"
  end
end
