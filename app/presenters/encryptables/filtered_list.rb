# frozen_string_literal: true

module ::Encryptables
  class FilteredList < ::FilteredList

    def fetch_entries
      filtered_encryptables = encryptables

      filtered_encryptables = filter_by_recent if recent.present? && true?(recent)
      filtered_encryptables = filter_by_query(filtered_encryptables) if query_present?


      filtered_encryptables
    end

    private

    def query
      @params[:q].strip.downcase
    end

    def query_present?
      @params[:q].present?
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

    def filter_by_query(encryptables)
      encryptables.where(
        'lower(encryptables.description) LIKE :query
        OR lower(encryptables.name) LIKE :query',
        query: "%#{query}%")
    end

    def filter_by_recent
      logs = PaperTrail::Version.where(whodunnit: @current_user.id)
      logs = logs.sort { |a, b| b.created_at <=> a.created_at }

      credential_ids = []
      logs.each do |log|
        credential_ids.push(log.item_id)
      end

      recent_credential_ids = credential_ids.uniq.first(limit.to_i)

      @current_user.encryptables.find(recent_credential_ids)
    end
  end
end
