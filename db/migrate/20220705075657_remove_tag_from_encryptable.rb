class RemoveTagFromEncryptable < ActiveRecord::Migration[7.0]
  def change
    remove_column :encryptables, :tag
  end
end
