# frozen_string_literal: true

class Api::FileEntriesController < ApiController
  self.permitted_attrs = [:filename, :description, :encryptable_id, :file]

  helper_method :team

  # GET /encryptables/:id/file_entries
  def index(options = {})
    authorize(team, :team_member?, policy_class: TeamPolicy)
    render({ json: fetch_entries,
             each_serializer: list_serializer,
             root: model_root_key.pluralize }
           .merge(render_options)
           .merge(options.fetch(:render_options, {})))
  end

  # GET /encryptables/:id/file_entries/:id
  def show
    authorize entry

    file = entry.decrypt(plaintext_team_password(team))

    send_data file, filename: entry.filename,
                    type: entry.content_type, disposition: 'attachment'
  end

  private

  def fetch_entries
    encryptable.file_entries
  end

  def build_entry
    instance_variable_set(:"@#{ivar_name}",
                          FileEntry.create(encryptable, model_params,
                                           plaintext_team_password(team)))
  end

  def encryptable
    @encryptable ||= Encryptable.find(params[:encryptable_id])
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

  def model_params
    params.permit(permitted_attrs)
  end
end
