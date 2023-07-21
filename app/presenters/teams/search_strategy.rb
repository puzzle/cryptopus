# frozen_string_literal: true

module ::Teams
  class SearchStrategy
    def search(query, teams)
      if get_database_adapter.include?('postgres')
        PgSearching.new.search(query, teams)
      else
        SqlSearch.new.search(query, teams)
      end
    end

    def get_database_adapter
      Rails.configuration.database_configuration[Rails.env]['adapter']
    end
  end
end
