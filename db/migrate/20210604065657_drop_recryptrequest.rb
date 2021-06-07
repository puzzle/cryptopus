class DropRecryptrequest < ActiveRecord::Migration[6.1]
  def change
    drop_table :recryptrequests
    remove_column :user, :recryptrequests
  end
end
