# frozen_string_literal: true

class Api::EncryptablesController < ApiController

  self.permitted_attrs = [:name, :description, :receiver_id]

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
    validate_receiver unless receiver_id.nil?
    build_entry
    authorize entry

    unless entry.transferred?
      entry.encrypt(decrypted_team_password(team))
    end

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

  def transfer_file
    shared_file = EncryptableTransfer.new.transfer(entry, User.find(receiver_id), current_user)

    instance_variable_set(:"@#{ivar_name}", shared_file)
    add_info('flashes.encryptable_transfer.file.transferred') if entry.type == Encryptable::File
  end

  def receiver_id
    params.dig('data', 'attributes', 'receiver_id')
  end

  # rubocop:disable Metrics/MethodLength
  def model_class
    case action_name
    when 'create'
      define_model_class
    else
      if ose_secret?
        Encryptable::OseSecret
      elsif entry_id.present?
        Encryptable.find(entry_id).class
      elsif fetch_entries.empty?
        Encryptable::File
      else
        Encryptable::Credentials
      end
    end
  end
  # rubocop:enable Metrics/MethodLength

  def define_model_class
    if ose_secret?
      Encryptable::OseSecret
    elsif receiver_id.present? || credential_id.present?
      Encryptable::File
    else
      Encryptable::Credentials
    end
  end

  def build_entry
    return build_encryptable_file if receiver_id.present? || encryptable_file?

    super
  end

  def file_credential
    Encryptable::Credentials.find(credential_id)
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def fetch_entry
    model_scope.find(entry_id)
  end

  def entry_id
    params[:id] || params.dig('data', 'attributes', 'id')
  end

  def encryptable_file?
    model_class == Encryptable::File
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

    if model_class == Encryptable::OseSecret
      permitted_attrs + [:cleartext_ose_secret, :folder_id]
    elsif model_class == Encryptable::File
      permitted_attrs + [:filename, :credentials_id, :file]
    elsif model_class == Encryptable::Credentials
      permitted_attrs + [:cleartext_username, :cleartext_password, :folder_id]
    else
      []
    end
  end

  def validate_receiver
    raise StandardError.new, 'Receiver user not found' unless User.exists?(receiver_id)
    raise StandardError.new, 'Cant transfer to Api user' if User.find(receiver_id).is_a?(User::Api)

    add_info('flashes.encryptable_transfer.file.transfer_failed')
  end

  ### Entries ###

  def fetch_entries
    return fetch_encryptable_files if credential_id.present?

    encryptables = user_encryptables

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

    inbox_folder_receiver = receiver.inbox_folder if receiver_id.present?

    file = new_file(file_credential, inbox_folder_receiver, params[:description], filename)
    file.content_type = params[:file].content_type
    file.cleartext_file = params[:file].read

    instance_variable_set(:"@#{ivar_name}", file)

    transfer_file if receiver_id.present?
  end

  def new_file(parent_encryptable, inbox_folder_receiver, description, name)
    Encryptable::File.new(encryptable_credential: parent_encryptable,
                          folder: inbox_folder_receiver,
                          description: description,
                          name: name)
  end

  def credential_id
    return params[:id] if params[:id].present?

    params[:credential_id]
  end

  def receiver
    return nil if receiver_id.nil?

    User.find(receiver_id)
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

  def ose_secret?
    params.dig('data', 'attributes', 'type') == 'ose_secret'
  end
end
