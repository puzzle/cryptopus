# frozen_string_literal: true

class Api::PersonalLogsController < ApiController
    self.permitted_attrs = :whodunnit
  
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
      logs = current_user.encryptables.all.versions.find_by!(whodunnit: params[:current_user.id])
      logs.sort { |a, b| b.created_at <=> a.created_at }
    end
  
    def list_serializer
      @model_serializer ||= 'LogsSerializer'.constantize
    end
  
    def team
      @team ||= Encryptable.all.folder.team
    end
  end
  