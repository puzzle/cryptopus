# frozen_string_literal: true

require_dependency '../utils/sharing/encryptable'

module Encryptables
  extend ActiveSupport::Concern

  ### Entries ###

  def fetch_entries
    return fetch_encryptable_files if credential_id.present?

    encryptables = user_encryptables
    if tag_param.present?
      encryptables = encryptables.find_by(tag: tag_param)
    end
    encryptables
  end

  def render_entry(options = nil)
    return send_file(options) if encryptable_file? && action_name != 'create'

    super(options)
  end

  ### Files ###

  def send_file(options)
    send_data(entry.cleartext_file, { filename: entry.name,
                                      type: entry.content_type,
                                      disposition: 'attachment' }
                                      .merge(options || {}))
  end

  def fetch_encryptable_files
    Encryptable::File.where(credential_id: user_encryptables.pluck(:id))
                     .where(credential_id: credential_id)
  end

  def build_encryptable_file
    filename = params[:file].original_filename
    file = new_file(file_credential, params[:description], filename)
    file.content_type = params[:file].content_type
    file.cleartext_file = params[:file].read

    instance_variable_set(:"@#{ivar_name}", file)
  end

  def new_file(parent_encryptable, description, name)
    Encryptable::File.new(encryptable_credential: parent_encryptable,
                          description: description,
                          name: name)
  end

  def credential_id
    return encryptable.credential_id if params[:id].present?

    params[:credential_id]
  end

  ### Sharing ###

  def encryptable_sharing?
    receiver_id.present?
  end

  def shared_encryptable
    options = {
      decrypted_team_password: decrypted_team_password(team)
    }
     shared_encryptable = Encryptable::Sharing.new(encryptable, receiver_id, options).prepare_encryptable
    instance_variable_set(:"@#{ivar_name}", shared_encryptable)
  end

  def is_shared_encryptable(entry)
    entry.transfer_password != nil && entry.receiver_id != nil
  end

  def receiver_id
      params[:receiver_id]
  end

  def decrypt_shared_encryptable(entry)
    plaintext_transfer_password = Crypto::Rsa.decrypt(entry.transfer_password, current_user.private_key)
    # entry.decrypt(plaintext_transfer_password)
  end

  ### Other ###

  def encrypt(encryptable)
    if encryptable.folder_id_changed?
      # if folder id changed recheck team permission
      authorize encryptable
      # move handler calls encrypt implicit
      encryptable_move_handler.move
    else
      encryptable.encrypt(decrypted_team_password(team))
    end
  end

  def create_ose_secret?
    action_name == 'create' &&
    params.dig('data', 'attributes', 'type') == 'ose_secret'
  end

  def encryptable
    @encryptable ||= Encryptable.find(params[:id])
  end
end
