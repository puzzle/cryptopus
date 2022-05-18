# frozen_string_literal: true

class Api::PersonalLogsController < ApiController
  before_action :skip_authorization

  self.permitted_attrs = :whodunnit

  def index(options = {})
    render({ json: fetch_entries,
             each_serializer: PersonalLogsSerializer }
             .merge(render_options)
             .merge(options.fetch(:render_options, {})))
  end

  def fetch_entries
    PaperTrail.serializer = JSON
    offset = params[:load] || 0
    get_current_user_logs(offset)
  end

  def get_current_user_logs(offset)
    PaperTrail::Version
      .where(whodunnit: @current_user)
      .order(created_at: :desc)
      .select('versions.*, users.username as username, encryptables.name as encryptable_name,
               folders.name as folder_name, teams.name as team_name')
      .joins('INNER JOIN users ON versions.whodunnit = users.id
              INNER JOIN encryptables ON encryptables.id = versions.item_id
              INNER JOIN folders ON encryptables.folder_id = folders.id
              INNER JOIN teams ON folders.team_id = teams.id')
      .offset(offset).limit(25)
  end
end
