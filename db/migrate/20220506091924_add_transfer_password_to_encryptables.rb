class AddTransferPasswordToEncryptables < ActiveRecord::Migration[7.0]
  def change
    add_column :encryptables, :encrypted_transfer_password, :string
    add_column :encryptables, :sender_id, :integer
  end
end
