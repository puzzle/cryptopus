class CreateSharedEncryptables < ActiveRecord::Migration[7.0]
  def change
    create_table :shared_encryptables do |t|
      t.integer :encryptable_id, null: false
      t.integer :sender_id, null: false
      t.integer :receiver_id, null: false
      t.boolean :is_read, default: false
      t.binary :share_password, null: false

    end
  end
end
