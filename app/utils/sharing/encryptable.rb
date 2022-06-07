# frozen_string_literal: true

class Encryptable::Sharing

  def initialize(encryptable, receiver_id, options = {})
    @encryptable = encryptable
    @receiver_id = receiver_id
    @options = options
  end

  def prepare_encryptable
    plaintext_transfer_password = new_transfer_password
    duplicated_encryptable = duplicate_encryptable

    duplicated_encryptable.encrypt(plaintext_transfer_password)

    receiver_public_key = User.find(@receiver_id).public_key
    encrypted_transfer_password = Crypto::Rsa.encrypt(
      plaintext_transfer_password,
      receiver_public_key
    )
    duplicated_encryptable = update_duplicated_encryptable(
      duplicated_encryptable,
      encrypted_transfer_password
    )
    begin
      duplicated_encryptable.save!
    rescue
      flash[:error] = duplicated_encryptable.errors.first.message
    end

    duplicated_encryptable
  end

  private

  def new_transfer_password
    Crypto::Symmetric::Aes256.random_key
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
    duplicated_encryptable.receiver_id = @receiver_id
    receiver_user = User.find(@receiver_id)

    receiver_personal_team_id = receiver_user.personal_team.id

    Folder.find_each do |folder|
      if folder.team_id == receiver_personal_team_id
        personal_team_folder_id = folder.id
        duplicated_encryptable.folder_id = personal_team_folder_id
      end
    end

    duplicated_encryptable.name << ' ' + receiver_user.username
    duplicated_encryptable
  end

end
