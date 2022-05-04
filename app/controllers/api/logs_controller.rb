# frozen_string_literal: true

class Api::LogsController < ApiController

  def index(options = {})
    authorize(team, :index?, policy_class: LogPolicy)
    render({ json: fetch_entries,
             each_serializer: @model_serializer ||= LogsSerializer }
      .merge(render_options)
      .merge(options.fetch(:render_options, {})))
  end

  def fetch_entries
    PaperTrail.serializer = JSON
    logs = current_user.encryptables.find_by!(id: params[:encryptable_id]).versions
    if params[:load]
      logs.last(params[:load]).sort { |a, b| b.created_at <=> a.created_at }
    else
      logs.last(10).sort { |a, b| b.created_at <=> a.created_at }
    end
  end

  def team
    @team ||= Encryptable.find(params[:encryptable_id]).folder.team
  end
end
