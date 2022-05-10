# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module Encryptables
  extend ActiveSupport::Concern

  ### Entries ###

  def fetch_entries
    return fetch_file_entries if credential_id.present?

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
                                      type: entry.cleartext_content_type,
                                      disposition: 'attachment' }
                                      .merge(options || {}))
  end

  def fetch_file_entries
    Encryptable::File.where(credential_id: user_encryptables.pluck(:id))
                     .where(credential_id: credential_id)
  end

  def build_encryptable_file
    filename = params[:file].original_filename
    file = new_file(file_credential, params[:description], filename)
    file.cleartext_file = params[:file].read
    file.cleartext_content_type = params[:file].content_type

    instance_variable_set(:"@#{ivar_name}", file)
  end

  def new_file(parent_encryptable, description, name)
    Encryptable::File.new(folder_id: parent_encryptable.folder_id,
                          encryptable_credential: parent_encryptable,
                          description: description,
                          name: name)
  end

  def credential_id
    return encryptable.credential_id if params[:id].present?

    params[:credential_id]
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

end
