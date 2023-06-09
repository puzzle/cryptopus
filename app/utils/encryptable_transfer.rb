# frozen_string_literal: true

require 'securerandom'

class EncryptableTransfer

  INCREMENT_REGEX = /\((\d+)\)/

  def transfer(encryptable, receiver, sender)
    transfer_password = new_transfer_password
    encryptable.encrypt(transfer_password)

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
    encryptable_name = encryptable.name

    inbox_folder_names = receiver.inbox_folder.encryptables.pluck(:name)
    return encryptable_name if inbox_folder_names.empty?

    matching_inbox_names = find_existing_names(encryptable_name, inbox_folder_names).sort
    is_file = encryptable.type == 'Encryptable::File'

    return encryptable_name if matching_inbox_names.empty?

    last_matched_inbox_name = matching_inbox_names.last
    adjust_encryptable_name(encryptable_name, is_file, last_matched_inbox_name)
  end

  def adjust_encryptable_name(encryptable_name, is_file, last_matched_inbox_name)
    unless is_file
      encryptable_name_regex = Regexp.escape(encryptable_name)
      return encryptable_name unless climbs_at_name_end(encryptable_name, encryptable_name_regex)
    end

    increase_encryptable_name(encryptable_name, is_file, last_matched_inbox_name)
  end

  def increase_encryptable_name(encryptable_name, is_file, last_matched_inbox_name)
    return file_destination_name(encryptable_name) if is_file

    if INCREMENT_REGEX.match(last_matched_inbox_name)
      "#{last_matched_inbox_name} (1)"
    else
      "#{encryptable_name} (1)"
    end
  end

  def file_destination_name(file_name)
    random_hash = SecureRandom.hex(3) # Generate a random hex string with 3 bytes (6 characters)
    random_hash = random_hash[0...5]  # Extract the first 5 characters

    file_name.sub(/(\.[^.]+)\z/, "(#{random_hash})\\1")
  end

  def find_existing_names(new_encryptable_name, inbox_folder_names)
    encryptable_name_regex = Regexp.escape(new_encryptable_name)

    inbox_folder_names.select do |name|
      climbs_at_name_end(name, encryptable_name_regex)
    end
  end

  def climbs_at_name_end(name, encryptable_name_regex)
    name.match?(/^(?:#{encryptable_name_regex}(?: \(\d+\))*|#{encryptable_name_regex})$/)
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
