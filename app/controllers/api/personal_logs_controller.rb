# frozen_string_literal: true

class Api::PersonalLogsController < ApiController
  before_action :skip_authorization

  self.permitted_attrs = :whodunnit

  def index(options = {})
    render({ json: fetch_entries,
             each_serializer: LogsSerializer }
             .merge(render_options)
             .merge(options.fetch(:render_options, {})))
  end

  def fetch_entries
    PaperTrail.serializer = JSON
    limit = params[:load] || 25
    PaperTrail::Version
      .where(whodunnit: @current_user)
      .order(created_at: :desc)
      .limit(limit)
  end
end
