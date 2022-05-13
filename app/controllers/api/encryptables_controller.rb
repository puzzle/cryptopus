# frozen_string_literal: true

class Api::EncryptablesController < ApiController
  include Encryptables

  self.permitted_attrs = [:name, :description, :folder_id, :tag]
  types_whitelist = [
    Encryptable::File.sti_name,
    Encryptable::Credentials.sti_name,
    Encryptable::OseSecret.sti_name
  ]

  helper_method :team

  # GET /api/encryptables
  def index(options = {})
    authorize Encryptable
    render({ json: fetch_entries,
             root: model_root_key.pluralize }
           .merge(render_options)
           .merge(options.fetch(:render_options, {})))
  end

  # GET /api/encryptables/:id
  def show
    authorize entry
    entry.decrypt(decrypted_team_password(team))
    render_entry
  end

  # options param is needed for render_entry method
  # POST /api/encryptables
  def create(options = {})
    require 'pry'; binding.pry unless $pstop
    build_entry
    authorize entry

    entry.encrypt(decrypted_team_password(team))

    if entry.save
      render_entry({ status: :created }
                     .merge(options[:render_options] || {}))
    else
      render_errors
    end
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
    if params[:type].present?
      model_class_from_params
    else
      Encryptable
    end
  end

  def model_class_from_params
    type = params[:type]
    klass = type.constantize

    if types_whitelist.exclude?(klass)
      # TODO: translate
      entry.errors.add(:base, "Type invalid")
    end

    klass
  end

  def build_entry
    return build_encryptable_file if encryptable_file?

    super
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
    EncryptableMoveHandler.new(entry, session[:private_key], current_user)
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
      permitted_attrs << :cleartext_ose_secret
    elsif model_class == Encryptable::File
      permitted_attrs + [:filename, :credentials_id, :file]
    elsif model_class == Encryptable::Credentials
      permitted_attrs + [:cleartext_username, :cleartext_password]
    else
      permitted_attrs
    end
  end
end
