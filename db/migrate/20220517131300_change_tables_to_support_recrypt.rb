class ChangeTablesToSupportRecrypt < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :recrypt_state, :integer, default: Team.recrypt_states[:done], null: false
    add_column :teams, :encryption_algorithm, :string

    set_default_encryption_algorithm
  end

  private

  def set_default_encryption_algorithm
    Team.update_all(encryption_algorithm: 'AES256')
  end
end
