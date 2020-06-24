# frozen_string_literal: true

module Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      return filter_by_query if query_present?
      return filter_by_id if team_id.present?

      teams
    end

    private

    def query
      @params[:q].strip.downcase
    end

    def query_present?
      @params[:q].present?
    end

    def teams
      @current_user.teams
    end

    def team_id
      @params[:team_id]
    end

    def filter_by_query
      teams.includes(:folders, folders: [:accounts]).where(
        'lower(teams.name) LIKE :query
        OR lower(folders.name) LIKE :query
        OR lower(accounts.accountname) LIKE :query
        OR lower(accounts.description) LIKE :query',
        query: "%#{query}%"
      )
           .references(:folders,
                       folders: [:accounts])
    end

    def filter_by_id
      [Team.find(team_id)]
    end
  end
end
