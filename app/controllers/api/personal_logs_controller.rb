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
    offset = params[:load] || 0
    Version
      .where(whodunnit: @current_user)
      .order(created_at: :desc)
      .includes(:user, :encryptable, encryptable: [:folder, { folder: [:team] }])
      .offset(offset)
      .limit(25)
  end
end
