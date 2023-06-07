# frozen_string_literal: true

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
    return encryptable_name if receiver.inbox_folder.encryptables.empty?

    inbox_folder_names = receiver.inbox_folder.encryptables.pluck(:name)
    matching_inbox_names = find_existing_names(encryptable_name, inbox_folder_names).sort
    is_file = encryptable.type == 'Encryptable::File'

    if matching_inbox_names.count == 1
      if matching_inbox_names[0] == encryptable_name
        # If name is already in inbox add (1)
        encryptable_name = increase_encryptable_name(encryptable_name, is_file, 1)
      end
    elsif matching_inbox_names.count > 1
      last_matched_inbox_name = matching_inbox_names.last
      # Remove (NUMBER) from encryptable name if present
      if INCREMENT_REGEX.match(encryptable_name)
        encryptable_name = encryptable_name.slice(0..-5)
      end
      # Get last encryptable number in climbs
      increasement = INCREMENT_REGEX.match(last_matched_inbox_name)[1].to_i

      encryptable_name = increase_encryptable_name(encryptable_name, is_file, increasement + 1)
    end

    encryptable_name
  end

  def increase_encryptable_name(encryptable_name, is_file, increasement)
    if is_file
       file_destination_name(encryptable_name, increasement)
     else
       encryptable_name + " (#{increasement})"
     end
  end

  def file_destination_name(file_name, increasement)
    parts = file_name.split('.')
    "#{parts[0]}(#{increasement}).#{parts[1]}"
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
