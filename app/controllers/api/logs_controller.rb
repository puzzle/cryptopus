# frozen_string_literal: true

class Api::LogsController < ApiController
  self.permitted_attrs = :encryptable_id

  def index(options = {})
    authorize(team, :index?, policy_class: LogPolicy)
    render({ json: fetch_entries,
             each_serializer: list_serializer,
             root: 'Logs_'.pluralize }
             .merge(render_options)
             .merge(options.fetch(:render_options, {})))
  end

  def fetch_entries
    PaperTrail.serializer = JSON
    logs = current_user.encryptables.find_by!(id: params[:encryptable_id]).versions
    logs.sort { |a, b| b.created_at <=> a.created_at }
  end

  def list_serializer
    @model_serializer ||= 'LogsSerializer'.constantize
  end

  def team
    @team ||= Encryptable.find(params[:encryptable_id]).folder.team
  end
end
