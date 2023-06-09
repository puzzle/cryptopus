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

    inbox_folder_names = receiver.inbox_folder.encryptables.pluck(:name)
    return encryptable_name if inbox_folder_names.empty?
    require 'pry'; binding.pry unless $pstop

    matching_inbox_names = find_existing_names(encryptable_name, inbox_folder_names).sort
    is_file = encryptable.type == 'Encryptable::File'

    return encryptable_name if matching_inbox_names.empty?

    last_matched_inbox_name = matching_inbox_names.last
    adjust_encryptable_name(last_matched_inbox_name, encryptable_name, is_file)
  end

  def adjust_encryptable_name(last_matched_inbox_name, encryptable_name, is_file)
    unless is_file
      encryptable_name_regex = Regexp.escape(encryptable_name)
      return encryptable_name unless climbs_at_name_end(encryptable_name, encryptable_name_regex)
    end

    if INCREMENT_REGEX.match(last_matched_inbox_name)
      number_to_increase = INCREMENT_REGEX.match(last_matched_inbox_name)[1].to_i
      increase_encryptable_name(encryptable_name, is_file, number_to_increase + 1)
    else
      increase_encryptable_name(encryptable_name, is_file, 1)
    end
  end

  def increase_encryptable_name(encryptable_name, is_file, number_to_increase)
    if is_file
      file_destination_name(encryptable_name, number_to_increase)
    else
      if INCREMENT_REGEX.match(encryptable_name)
        # Remove last (NUMBER) from encryptable name if present
        encryptable_name = encryptable_name.sub(/\s\(\d+\)\z/, '')
      end
      encryptable_name + " (#{number_to_increase})"
    end
  end

  def file_destination_name(file_name, number_to_increase)
    if file_name.match(INCREMENT_REGEX)
      file_name.gsub(INCREMENT_REGEX) do
        "(#{number_to_increase})"
      end
    else
      file_name.sub(/(\.[^.]+)\z/, "(#{number_to_increase})\\1")
    end
  end

  def find_existing_names(new_encryptable_name, inbox_folder_names)
    encryptable_name_regex = Regexp.escape(new_encryptable_name)

    inbox_folder_names.select do |name|
      climbs_at_name_end(name, encryptable_name_regex)
    end
  end

  def climbs_at_name_end(name, encryptable_name_regex)
    name.match?(/^(?:#{encryptable_name_regex}(?: \(\d+\))?|#{encryptable_name_regex})$/)
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
