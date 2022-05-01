# frozen_string_literal: true

module ::Encryptables
  class FilteredList < ::FilteredList

    def fetch_entries
      filtered_encryptables = encryptables

      filtered_encryptables = filter_by_recent if recent.present? && true?(recent)
      filtered_encryptables = filter_by_tag_params if tag_param.present?

      filtered_encryptables
    end

    private

    def filter_by_tag_params
      encryptables = encryptables.find_by(tag: tag_param)
    end

    def tag_param
      @params[:tag]
    end

    def recent
      @params[:recent]
    end

    def encryptables
      @current_user.encryptables
                   .limit(limit)
    end

    def limit
      @params[:limit]
    end

    def filter_by_recent
      logs = PaperTrail::Version.where(whodunnit: @current_user.id)
      logs = logs.sort { |a, b| b.created_at <=> a.created_at }
  
      credentialIds = []
      for log in logs do
        credentialIds.push(log.item_id)
      end
  
      recentCredentialIds = credentialIds.uniq.first(limit.to_i)
  
      recentCredentials = @current_user.encryptables.find(recentCredentialIds)
    end
  end
end
