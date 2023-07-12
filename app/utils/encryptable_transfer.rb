# frozen_string_literal: true

class EncryptableTransfer

  def transfer(encryptable, receiver, sender)
    transfer_password = transfer_password(receiver)
    encryptable.encrypt(transfer_password, encryption_algorithm)

    encryptable.name = encryptable_destination_name(encryptable, receiver)

    encryptable.update!(
      folder: receiver.inbox_folder,
      sender_id: sender.id,
      encrypted_transfer_password:
        Base64.encode64(encrypted_transfer_password(transfer_password, receiver))
    )
    encryptable
  end

  def receive(encryptable, private_key, personal_team_password)
    encryptable.decrypt_transferred(private_key)

    encryptable.encrypt(personal_team_password)
    encryptable.decrypt(personal_team_password)

    encryptable.encrypted_transfer_password = nil
    encryptable.save!

    encryptable
  end

  private

  def encryptable_destination_name(encryptable, receiver)
    existing_names = receiver.inbox_folder.encryptables.pluck(:name)
    is_file = encryptable.is_a?(Encryptable::File)

    transfered_name(encryptable.name, existing_names, is_file).destination_name
  end

  def encrypted_transfer_password(password, receiver)
    Crypto::Rsa.encrypt(
      password,
      receiver.public_key
    )
  end

  def transfer_password(receiver)
    encryption_algorithm = receiver.personal_team.encryption_algorithm
    encryption_algorithm = Crypto::Symmetric::ALGORITHMS[encryption_algorithm]
    encryption_algorithm.random_key
  end

  def transfered_name(name, existing_names, is_file)
    EncryptableTransferedName.new(name, existing_names, is_file)
  end

end
