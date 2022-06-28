# frozen_string_literal: true

class Api::EncryptablesController < ApiController
  include Encryptables

  self.permitted_attrs = [:name, :description, :tag]

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
    entry.decrypt(decrypted_team_password(team))
    render_entry
  end

  # options param is needed for render_entry method
  # POST /api/encryptables
  def create
    build_entry
    authorize entry

    entry.encrypt(decrypted_team_password(team))

    if entry.save
      render_entry({ status: :created })
    else
      render_errors
    end
  end

  # PATCH /api/encryptables/:id?Query
  def update
    authorize encryptable
    encryptable.attributes = model_params

    encrypt(encryptable)

    if encryptable.save
      render_json encryptable
    else
      render_errors
    end
  end

  private

  # rubocop:disable Metrics/MethodLength
  def model_class
    if create_ose_secret?
      Encryptable::OseSecret
    elsif action_name == 'destroy'
      Encryptable
    elsif @encryptable.present?
      encryptable.class
    elsif credential_id.present?
      Encryptable::File
    else
      Encryptable::Credentials
    end
  end
  # rubocop:enable Metrics/MethodLength

  def build_entry
    return build_encryptable_file if encryptable_file?

    super
  end

  def file_credential
    Encryptable::Credentials.find(credential_id)
  end

  def encryptable
    @encryptable ||= Encryptable.find(params[:id])
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

  def tag_param
    params[:tag]
  end

  def encryptable_move_handler
    EncryptableMoveHandler.new(encryptable, session[:private_key], current_user)
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
end
