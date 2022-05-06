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
    PaperTrail::Version
      .where(whodunnit: @current_user)
      .order(created_at: :desc)
  end
end
