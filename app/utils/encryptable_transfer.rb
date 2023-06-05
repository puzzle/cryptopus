# frozen_string_literal: true

class EncryptableTransfer

  INCREMENT_REGEX = / \((\d+)\)/

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

    matching_inbox_names = find_existing_names(encryptable_name, inbox_folder_names)

    return encryptable_name if matching_inbox_names.empty?

    target_name(encryptable_name, matching_inbox_names)
  end

  def target_name(encryptable_name, existing_names)
    last_matched_inbox_name = existing_names.last

    if INCREMENT_REGEX.match(last_matched_inbox_name) && INCREMENT_REGEX.match(encryptable_name)
      # Update number in climbs when there is already a number in the name
      encryptable_name = encryptable_name.slice(0..-4)
      encryptable_name = increase_encryptable_name(last_matched_inbox_name, encryptable_name)
    elsif !INCREMENT_REGEX.match(encryptable_name)
      # If encryptable name is already in inbox_folder, add a (1) to name
      if existing_names.include?(encryptable_name)
        encryptable_name = increase_encryptable_name(last_matched_inbox_name, encryptable_name)
      end
    end

    encryptable_name
  end

  def increase_encryptable_name(last_matched_inbox_name, encryptable_name)
    increment_regex_match = INCREMENT_REGEX.match(last_matched_inbox_name)

    if increment_regex_match
      increasement = INCREMENT_REGEX.match(last_matched_inbox_name)[1].to_i
      "#{encryptable_name} (#{increasement + 1})"
    else
      "#{encryptable_name} (1)"
    end
  end

  def find_existing_names(new_encryptable_name, inbox_folder_names)
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
