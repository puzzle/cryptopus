# frozen_string_literal: true

module ::Teams
  class SearchStrategy
    def search(query, teams)
      if database_adapter.include?('postgres')
        PgSearching.new.search(query, teams)
      else
        SqlSearch.new.search(query, teams)
      end
    end

    def database_adapter
      Rails.configuration.database_configuration[Rails.env]['adapter']
    end
  end
end
