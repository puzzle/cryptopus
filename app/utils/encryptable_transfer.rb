# frozen_string_literal: true

class EncryptableTransfer
  def transfer(encryptable, receiver, sender)
    transfer_password = new_transfer_password
    encryptable.encrypt(transfer_password)

    encryptable.update!(
      folder: receiver.inbox_folder,
      sender_id: sender.id,
      encrypted_transfer_password: encrypted_transfer_password(transfer_password, receiver)
    )
    encryptable
  end

  def receive(encryptable, private_key, personal_team_password)
    encryptable.decrypt_transfered(private_key)

    encryptable.encrypt(personal_team_password)
    encryptable.decrypt(personal_team_password)

    encryptable.encrypted_transfer_password = nil
    encryptable.save!

    encryptable
  end

  private

  def encrypted_transfer_password(password, receiver)
    Crypto::Rsa.encrypt(
        password,
        receiver.public_key
      )
  end

  def new_transfer_password
    Crypto::Symmetric::Aes256.random_key
  end

end

