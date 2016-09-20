class RemoveColumnAdminAndRootrequired < ActiveRecord::Migration
  def change
    remove_column :recryptrequests, :adminrequired, :boolean
    remove_column :recryptrequests, :rootrequired, :boolean
  end
end
