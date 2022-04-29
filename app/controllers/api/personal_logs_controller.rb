# frozen_string_literal: true

class Api::PersonalLogsController < ApiController
    before_action :skip_authorization

    self.permitted_attrs = :whodunnit
  
    def index(options = {})
      render({ json: fetch_entries,
               each_serializer: list_serializer,
               root: 'Logs_'.pluralize }
               .merge(render_options)
               .merge(options.fetch(:render_options, {})))
    end
  
    def fetch_entries
      PaperTrail.serializer = JSON
      logs = PaperTrail::Version.find_by!(whodunnit: current_user.id)
      # logs.sort { |a, b| b.created_at <=> a.created_at }
    end
  
    def list_serializer
      @model_serializer ||= 'LogsSerializer'.constantize
    end
  end
  