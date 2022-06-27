# frozen_string_literal: true

class EncryptableTransfer
  def transfer(encryptable, receiver, sender)
    transfer_password = new_transfer_password
    encryptable.encrypt(transfer_password)
    assert_human_receiver?(receiver)

    encryptable.update!(
      folder: inbox_folder(receiver),
      sender_id: sender.id,
      receiver_id: receiver.id,
      encrypted_transfer_password: encrypted_transfer_password(transfer_password, receiver)
    )
    encryptable
  end

  def receive(encryptable, private_key, personal_team_password)
    encryptable.decrypt_transfered(private_key)

    encryptable.update!(encrypted_transfer_password: nil,
                        receiver_id: nil,
                        sender_id: nil)

    encryptable.encrypt(personal_team_password)
    encryptable.decrypt(personal_team_password)

    encryptable
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

  def assert_human_receiver?(receiver)
    unless receiver.is_a?(User::Human)
      raise StandardError.new 'Receiver must be a human user'
    end
  end

end
