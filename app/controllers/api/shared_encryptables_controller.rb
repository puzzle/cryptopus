class Api::SharedEncryptablesController < ApiController

  self.permitted_attrs = [:encryptable_id, :receiver_id]

  def create
    authorize encryptable

    plaintext_transfer_password = Crypto::Symmetric::Aes256.random_key

    duplicated_encryptable = duplicate_decrypted_encryptable

    receiver_public_key = User.find(receiver_id).public_key
    transfer_password = encrypt_transfer_password(receiver_public_key, plaintext_transfer_password)

    duplicated_encryptable.encrypt(plaintext_transfer_password)

    duplicated_encryptable = update_duplicated_encryptable(duplicated_encryptable, transfer_password)
    duplicated_encryptable.save

  end

  private

  def current_user
    @current_user ||= (User::Human.find(session[:user_id]) if session[:user_id])
  end

  def encryptable
    @encryptable ||= Encryptable.find(encryptable_id)
  end

  def team
    @team ||= encryptable.folder.team
  end

  def receiver_id
    params[:data][:receiver_id]
  end

  def encryptable_id
    params[:data][:encryptable_id]
  end

  def duplicate_decrypted_encryptable
    encryptable.decrypt(decrypted_team_password(team))
    encryptable.dup
  end

  def encrypt_transfer_password(receiver_public_key, plaintext_transfer_password)
    plaintext_transfer_password.encrypt(receiver_public_key)
  end

  def update_duplicated_encryptable(duplicated_encryptable, transfer_password)
    duplicated_encryptable.transfer_password = transfer_password
    duplicated_encryptable.receiver_id = receiver_id
    duplicated_encryptable
  end

end
