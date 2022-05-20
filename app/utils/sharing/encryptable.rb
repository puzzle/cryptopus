# frozen_string_literal: true

class Encryptables::Sharing

  def new(encryptable_id, receiver_id)
    encryptable(encryptable_id)

    plaintext_transfer_password = new_transfer_password
    duplicated_encryptable = duplicate_decrypted_encryptable

    duplicated_encryptable.encrypt(plaintext_transfer_password)

    receiver_public_key = User.find(receiver_id).public_key
    encrypted_transfer_password = Crypto::Rsa.encrypt(plaintext_transfer_password, receiver_public_key)
    duplicated_encryptable = update_duplicated_encryptable(duplicated_encryptable, encrypted_transfer_password)
    duplicated_encryptable.save!   plaintext_transfer_password = new_transfer_password
    duplicated_encryptable = duplicate_decrypted_encryptable

    duplicated_encryptable.encrypt(plaintext_transfer_password)

    receiver_public_key = User.find(receiver_id).public_key
    encrypted_transfer_password = Crypto::Rsa.encrypt(plaintext_transfer_password, receiver_public_key)
    duplicated_encryptable = update_duplicated_encryptable(duplicated_encryptable, encrypted_transfer_password)
    duplicated_encryptable.save!
  end

  def share!

  end

  private

  def new_transfer_password
    Crypto::Symmetric::Aes256.random_key
  end

  def current_user
    @current_user ||= (User::Human.find(session[:user_id]) if session[:user_id])
  end

  def team
    @team ||= @encryptable.folder.team
  end

  def duplicate_encryptable
    @encryptable.decrypt(@options[:decrypted_team_password])
    @encryptable.dup
  end

  def update_duplicated_encryptable(duplicated_encryptable, transfer_password)
    duplicated_encryptable.transfer_password = transfer_password
    duplicated_encryptable.receiver_id = receiver_id
    duplicated_encryptable.folder_id = nil
    duplicated_encryptable
  end

end