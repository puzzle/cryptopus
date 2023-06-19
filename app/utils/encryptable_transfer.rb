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

    existing_encryptable_names = receiver.inbox_folder.encryptables.pluck(:name)
    return encryptable_name if existing_encryptable_names.empty?

    matching_inbox_names = find_existing_names(encryptable_name, existing_encryptable_names)
    return encryptable_name if matching_inbox_names.blank?

    is_file = encryptable.is_a?(Encryptable::File)
    latest_name = matching_inbox_names.last
    adjust_encryptable_name(encryptable_name, is_file, latest_name)
  end

  def adjust_encryptable_name(encryptable_name, is_file, latest_name)
    # Remove file datatype, so we can handle can increase name same as credentials
    if is_file
      suffix = File.extname(encryptable_name)
      encryptable_name = File.basename(encryptable_name, '.*')
    end

    increase_encryptable_name(encryptable_name, is_file, latest_name, suffix)
  end

  def increase_encryptable_name(encryptable_name, is_file, latest_name, suffix)
    # Remove (NUMBER) if it already exists in name
    if INCREMENT_REGEX.match(encryptable_name)
      encryptable_name = encryptable_name.sub(/\(\d+\)\z/, '')
    end

    # If last encryptable in inbox has (NUMBER) add (NUMBER + 1)
    encryptable_name += if INCREMENT_REGEX.match(latest_name)
                          "(#{INCREMENT_REGEX.match(latest_name)[1].to_i + 1})"
                        else
                          '(1)'
                        end

    encryptable_name += suffix if is_file

    encryptable_name
  end

  def find_existing_names(new_encryptable_name, existing_encryptable_names)
    return unless existing_encryptable_names.include?(new_encryptable_name)

    encryptable_suffix = File.extname(new_encryptable_name)
    encryptable_name = File.basename(new_encryptable_name, '.*')

    # For the loop through inbox encryptables remove (NUMBER) from name
    encryptable_name = remove_optional_climbs(encryptable_name)

    regex_pattern = /\A#{Regexp.escape(encryptable_name)}(\(\d+\))?\z/
    existing_encryptable_names.select do |name|
      current_suffix = File.extname(name)
      current_encryptable_name = File.basename(name, '.*')
      current_encryptable_name.match?(regex_pattern) && current_suffix == encryptable_suffix
    end
  end

  def remove_optional_climbs(encryptable_name)
    regex_pattern = /\A.*\(\d+\)\z/

    if encryptable_name.match?(regex_pattern)
      encryptable_name = encryptable_name.gsub(/\(\d+\)\z/, '')
    end

    encryptable_name
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
