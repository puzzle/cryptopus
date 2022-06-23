# frozen_string_literal: true

module ::Encryptables
  class FilteredList < ::FilteredList

    def fetch_entries
      filtered_encryptables = encryptables

      filtered_encryptables = filter_by_recent if recent?
      filtered_encryptables = filter_by_query(filtered_encryptables) if query


      filtered_encryptables
    end

    private

    def query
      @params[:q]&.strip&.downcase
    end

    def recent?
      true?(@params[:recent])
    end

    def encryptables
      @current_user.encryptables
    end

    def filter_by_query(encryptables)
      encryptables.where(
        'lower(encryptables.description) LIKE :query
        OR lower(encryptables.name) LIKE :query',
        query: "%#{query}%"
      )
    end

    def filter_by_recent
      Version
        .includes(:encryptable, encryptable: [:folder])
        .where(whodunnit: @current_user)
        .order(created_at: :desc)
        .group(:item_id, :item_type)
        .select(:item_id, :item_type)
        .limit(5)
        .map(&:encryptable)
    end
  end
end
