# frozen_string_literal: true

class Api::Encryptables::FileController < Api::EncryptablesController
  self.permitted_attrs = [:filename, :description, :encryptable_credentials_id, :file]

  def create
    build_encryptable_file
    authorize entry
    if entry.save
      render_entry({ status: :created }
                     .merge(options[:render_options] || {}))
    else
      render_errors
    end
  end

  private

  def build_encryptable_file
    filename = params[:file].original_filename
    file = new_file(encryptable_credential, params[:description], filename)
    file.cleartext_file = params[:file].read

    file.encrypt(plaintext_team_password(team))

    instance_variable_set(:"@#{ivar_name}", file)
  end

  def new_file(parent_encryptable, description, name)
    Encryptable::File.new(folder_id: parent_encryptable.folder_id,
                          encryptable_credential: parent_encryptable,
                          description: description,
                          name: name)
  end

  def ivar_name
    Encryptable::File.model_name.param_key
  end

  def encryptable_credential
    @account ||= Encryptable::Credentials.find(params[:encryptable_credentials_id])
  end

  def model_params
    params.permit(permitted_attrs)
  end

end
