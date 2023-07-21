# frozen_string_literal: true

module ::Teams
  class SqlSearch < SearchStrategy
    def self.search(query, teams)
      teams.where(
        'lower(encryptables.description) LIKE :query
        OR lower(encryptables.name) LIKE :query
        OR lower(folders.name) LIKE :query
        OR lower(teams.name) LIKE :query',
        query: "%#{query}%"
      )
           .references(:folders,
                       folders: [:encryptables])
    end
  end
end