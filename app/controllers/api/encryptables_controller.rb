# frozen_string_literal: true

class Api::EncryptablesController < ApiController

  self.permitted_attrs = [:name, :description, :file]

  helper_method :team

  # GET /api/encryptables
  def index
    authorize Encryptable
    render({ json: fetch_entries,
             root: model_root_key.pluralize }
           .merge(render_options))
  end

  # GET /api/encryptables/:id
  def show
    authorize entry

    if entry.transferred?
      personal_team = current_user.personal_team
      personal_team_password = decrypted_team_password(personal_team)
      EncryptableTransfer.new.receive(entry, session[:private_key], personal_team_password)
    else
      entry.decrypt(decrypted_team_password(team))
    end

    render_entry
  end

  # POST /api/encryptables
  def create
    build_entry
    authorize entry

    entry.encrypt(decrypted_team_password(team))

    entry.save ? render_entry({ status: :created }) : render_errors
  end

  # PATCH /api/encryptables/:id?Query
  def update
    authorize entry
    entry.attributes = model_params

    encrypt(entry)

    if entry.save
      render_json entry
    else
      render_errors
    end
  end

  private

  def model_class
    if action_name == 'create'
      define_model_class
    elsif entry_id.present?
      Encryptable.find(entry_id).class
    elsif fetch_entries.empty?
      Encryptable::File
    else
      Encryptable::Credentials
    end
  end

  def define_model_class
    if credential_id.present?
      Encryptable::File
    else
      Encryptable::Credentials
    end
  end

  def build_entry
    return build_encryptable_file if encryptable_file?

    super
  end

  def file_credential
    Encryptable::Credentials.find(credential_id)
  end

  def fetch_entry
    model_scope.find(entry_id)
  end

  def entry_id
    params[:id] || params.dig('data', 'attributes', 'id')
  end

  def encryptable_file?
    model_class == Encryptable::File && params[:encryptable].nil?
  end

  def user_encryptables
    current_user.encryptables
  end

  def team
    @team ||= entry.team
  end

  def query_param
    params[:q]
  end

  def encryptable_move_handler
    EncryptableMoveHandler.new(entry, users_private_key, current_user)
  end

  def ivar_name
    (encryptable_file? ? Encryptable::File : Encryptable).model_name.param_key
  end

  def model_serializer
    "#{model_class.name}Serializer".constantize
  end

  def permitted_attrs
    permitted_attrs = self.class.permitted_attrs.deep_dup

    if model_class == Encryptable::File
      permitted_attrs + [:filename, :credentials_id, :file]
    elsif model_class == Encryptable::Credentials
      permitted_attrs + [:cleartext_username, :cleartext_password, :cleartext_token, :cleartext_pin, :cleartext_email , :folder_id, cleartext_custom_attr: [:label, :value]]
    else
      []
    end
  end

  ### Entries ###

  def fetch_entries
    return fetch_encryptable_files if credential_id.present?

    user_encryptables
  end

  def render_entry(options = nil)
    return send_file(options) if encryptable_file? && action_name == 'show'

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
    Encryptable::File.where(credential_id: user_encryptables)
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
    return params[:id] if params[:id].present?

    params[:credential_id]
  end

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
end
