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
    limit = params[:load] || 20
    PaperTrail::Version
      .where(item_id: params[:encryptable_id])
      .order(created_at: :desc)
      .limit(limit)
  end

  def team
    @team ||= Encryptable.find(params[:encryptable_id]).folder.team
  end
end
