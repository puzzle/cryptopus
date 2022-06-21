class ChangeFileColumnSize < ActiveRecord::Migration[6.0]
  def up
    change_column :file_entries, :file, :binary, size: :medium
  end

  def down
    change_column :file_entries, :file, :binary
  end
end
