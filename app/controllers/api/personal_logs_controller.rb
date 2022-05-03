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
      recent_version = PaperTrail::Version
        .where(whodunnit:@current_user)
        .order(created_at: :desc)
    end
  
    def list_serializer
      @model_serializer ||= 'LogsSerializer'.constantize
    end
  end
  