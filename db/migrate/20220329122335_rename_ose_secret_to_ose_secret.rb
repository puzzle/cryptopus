class RenameOseSecretToOseSecret < ActiveRecord::Migration[7.0]
  def change
    execute "UPDATE encryptables SET type = 'Encryptable::OseSecret' WHERE type = 'Encryptables::OSESecret'"
  end
end
