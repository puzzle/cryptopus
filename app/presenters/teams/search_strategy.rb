# frozen_string_literal: true

module ::Teams
  class SearchStrategy
    def search(query, teams)
      if Rails.configuration.database_configuration[Rails.env]['database'].include?('postgres')
        PgSearching.new.search(query, teams)
      else
        SqlSearch.new.search(query, teams)
      end
    end
  end
end