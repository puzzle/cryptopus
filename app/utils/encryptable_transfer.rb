# frozen_string_literal: true

class EncryptableTransfer
  def transfer(encryptable, receiver, sender)
    transfer_password = new_transfer_password
    encryptable.encrypt(transfer_password)

    encryptable.name = encryptable_destination_name(encryptable.name, receiver)

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

  def encryptable_destination_name(encryptable_name, receiver)
    inbox_folder_names = receiver.inbox_folder.encryptables.pluck(:name)
    counter = 0

    loop do
      matching_inbox_names = find_matching_inbox_names(encryptable_name, inbox_folder_names)
      break if matching_inbox_names.empty?

      # rubocop:disable Metrics/LineLength
      new_encryptable_name = generate_new_encryptable_name(encryptable_name, counter, matching_inbox_names)
      # rubocop:enable Metrics/LineLength

      encryptable_name = new_encryptable_name
      counter += 1
    end
    encryptable_name
  end

  def generate_new_encryptable_name(encryptable_name, counter, matching_inbox_names)
    clip_regex = / \(\d+\)/


    matching_inbox_names.each do |inbox_encryptable_name|
      if clip_regex.match(inbox_encryptable_name) && clip_regex.match(encryptable_name)
        encryptable_name = encryptable_name.slice(0..-4)
        encryptable_name = "#{encryptable_name}(#{counter + 1})"
      else
        encryptable_name = "#{encryptable_name} (#{counter + 1})"
      end
    end

    encryptable_name
  end

  def find_matching_inbox_names(new_encryptable_name, inbox_folder_names)
    encryptable_name_regex = Regexp.escape(new_encryptable_name)

    inbox_folder_names.select do |name|
      name.match?(/^(?:#{encryptable_name_regex}(?: \(\d+\))?|#{encryptable_name_regex})$/)
    end
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
