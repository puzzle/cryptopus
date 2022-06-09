class RenamePasswordToEncryptedTeamPassword < ActiveRecord::Migration[7.0]
  def change
    rename_column :teammembers, :password, :encrypted_team_password
  end
end
