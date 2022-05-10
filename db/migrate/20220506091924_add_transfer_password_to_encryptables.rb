class AddTransferPasswordToEncryptables < ActiveRecord::Migration[7.0]
  def change
    add_column :encryptables, :transfer_password, :binary
    add_column :encryptables, :receiver_id, :integer
  end
end
