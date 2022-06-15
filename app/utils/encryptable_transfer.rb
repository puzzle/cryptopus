# frozen_string_literal: true

class EncryptableTransfer

  def transfer(encryptable, receiver, sender_id)

    if receiver.nil?
      raise StandardError.new "Cant transfer to nonexistent user"
    elsif receiver.is_a?(User::Api)
      raise StandardError.new "Cant transfer to API user"
    else
      transfer_password = new_transfer_password
      encryptable.encrypt(transfer_password)

      encryptable.update!(
        folder: inbox_folder(receiver),
        sender_id: sender_id,
        encrypted_transfer_password: encrypted_transfer_password(transfer_password, receiver)
      )
    end
  end

  private

  def inbox_folder(receiver)
    personal_team = receiver.personal_team
    personal_team.folders.find_or_create_by(name: 'inbox')
  end

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

