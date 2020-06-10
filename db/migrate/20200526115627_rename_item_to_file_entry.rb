class RenameItemToFileEntry < ActiveRecord::Migration[6.0]
  def change
    rename_table :items, :file_entries
  end
end
