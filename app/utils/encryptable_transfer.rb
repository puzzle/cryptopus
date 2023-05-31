# frozen_string_literal: true

class EncryptableTransfer
  def transfer(encryptable, receiver, sender)
    transfer_password = new_transfer_password
    encryptable.encrypt(transfer_password)

    update_encryptable_name_if_not_unique(encryptable, receiver)

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

  def update_encryptable_name_if_not_unique(encryptable, receiver)
    # rubocop:disable Metrics/LineLength
    regex = /^(?:#{Regexp.escape(encryptable.name)}(?: \(\d+\))?|#{Regexp.escape(encryptable.name)})$/
    # rubocop:enable Metrics/LineLength

    counter = 0
    receiver.inbox_folder.encryptables.each do |inbox_encryptable|
      matching = regex.match(inbox_encryptable.name)
      counter += 1 if matching
    end

    encryptable.name = "#{encryptable.name} (#{counter})" if counter.positive?
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
