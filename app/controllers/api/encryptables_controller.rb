# frozen_string_literal: true

class Api::EncryptablesController < ApiController
  self.permitted_attrs = [:name, :description, :folder_id, :tag]

  before_action :set_paper_trail_whodunnit

  helper_method :team

  # GET /api/encryptables
  def index(options = {})
    if params['recent'].present?
      authorize Encryptable
        render({ json: fetch_recentCredentials,
        root: model_root_key.pluralize }
        .merge(render_options)
        .merge(options.fetch(:render_options, {})))
    else
    authorize Encryptable
    render({ json: fetch_entries,
             root: model_root_key.pluralize }
           .merge(render_options)
           .merge(options.fetch(:render_options, {})))
    end
  end

  def fetch_recentCredentials
    logs = PaperTrail::Version.where(whodunnit: current_user.id)
    logs = logs.sort { |a, b| b.created_at <=> a.created_at }

    credentialIds = []
    for log in logs do
      credentialIds.push(log.item_id)
    end
    for id in credentialIds do
      puts id
    end
    recentCredentialIds = credentialIds.uniq.first(5)

    recentCredentials = current_user.encryptables.find(recentCredentialIds)
    recentCredentials
  end
  
  # GET /api/encryptables/:id
  def show
    authorize encryptable
    encryptable.paper_trail_event = 'viewed'
    encryptable.touch
    encryptable.decrypt(decrypted_team_password(team))
    render_entry
  end

  # POST /api/encryptables
  def create
    build_entry
    authorize encryptable
    encryptable.encrypt(decrypted_team_password(team))
    if encryptable.save
      @response_status = :created
      render_json encryptable
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

  def model_class
    if action_name == 'create' &&
       params.dig('data', 'attributes', 'type') == 'ose_secret'
      Encryptable::OseSecret
    elsif action_name == 'destroy'
      Encryptable
    elsif @encryptable.present?
      encryptable.class
    else
      Encryptable::Credentials
    end
  end

  def fetch_entries
    encryptables = current_user.encryptables
    if tag_param.present?
      encryptables = encryptables.find_by(tag: tag_param)
    end
    encryptables
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

  def encryptable
    @encryptable ||= Encryptable.find(params[:id])
  end

  def team
    @team ||= encryptable.folder.team
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
    Encryptable.model_name.param_key
  end

  def model_serializer
    "#{model_class.name}Serializer".constantize
  end

  def permitted_attrs
    permitted_attrs = self.class.permitted_attrs.deep_dup

    if model_class == Encryptable::OseSecret
      permitted_attrs << :cleartext_ose_secret
    elsif model_class == Encryptable::Credentials
      permitted_attrs + [:cleartext_username, :cleartext_password]
    else
      permitted_attrs
    end
  end
end
