# frozen_string_literal: true

module ::Teams
  class QuerySearch < ::FilteredList
    def filter_by_query(teams, query)
      teams.search_with_pg(query)
    end
  end
end
