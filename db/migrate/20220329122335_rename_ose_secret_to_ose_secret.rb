class RenameOseSecretToOseSecret < ActiveRecord::Migration[7.0]
  def up
    execute "UPDATE encryptables SET type = 'Encryptable::OseSecret' WHERE type = 'Encryptable::OSESecret'"
  end

  def down
    execute "UPDATE encryptables SET type = 'Encryptable::OSESecret' WHERE type = 'Encryptable::OseSecret'"
  end
end
