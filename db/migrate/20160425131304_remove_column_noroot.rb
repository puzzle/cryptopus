class RemoveColumnNoroot < ActiveRecord::Migration
  def change
    remove_column :teams, :noroot
  end
end
