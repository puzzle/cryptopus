class ChangeTablesToSupportRecrypt < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :recrypt_state, :integer, default: 1, null: false
    add_column :teams, :encryption_algorithm, :string, default: 'AES256', null: false

    add_column :encryptables, :encryption_algorithm, :string, default: 'AES256', null: false
  end
end
