class ChangeTablesToSupportRecrypt < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :recrypt_state, :integer, default: 1, null: false
    add_column :teams, :encryption_algorithm, :string

    add_column :encryptables, :encryption_algorithm, :string

    set_default_encryption_algorithm

    change_column :teams, :encryption_algorithm, default: latest_algorithm, null: false
    change_column :encryptables, :encryption_algorithm, default: latest_algorithm, null: false
  end

  private

  def set_default_encryption_algorithm
    Team.update_all(encryption_algorithm: "AES256")
    Encryptable.update_all(encryption_algorithm: "AES256")
  end

  def latest_algorithm
    Crypto::Encryptable.latest_algorithm
  end
end
