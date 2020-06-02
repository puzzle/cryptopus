class RenameGroupsToFolders < ActiveRecord::Migration[6.0]

  def change
    rename_table :groups, :folders
    rename_column :accounts, :group_id, :folder_id
  end

end
