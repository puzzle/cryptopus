# frozen_string_literal: true

module ::Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      return filter_by_query if query_present?
      return filter_by_id if team_id.present?
      return filter_by_favourite if favourite.present?

      teams
    end

    private

    def query
      @params[:q].strip.downcase
    end

    def query_present?
      @params[:q].present?
    end

    def favourite
      @params[:favourite]
    end

    def teams
      @current_user.teams
                   .includes(:user_favourite_teams, :folders, folders: [:accounts])
                   .limit(limit)
    end

    def team_id
      @params[:team_id]
    end

    def limit
      @params[:limit]
    end

    def filter_by_query
      teams.includes(:folders, folders: [:accounts]).where(
        'lower(accounts.description) LIKE :query
        OR lower(accounts.accountname) LIKE :query
        OR lower(folders.name) LIKE :query
        OR lower(teams.name) LIKE :query',
        query: "%#{query}%"
      )
           .references(:folders,
                       folders: [:accounts])
    end

    def filter_by_id
      [Team.find(team_id)]
    end

    def filter_by_favourite
      @current_user.favourite_teams
    end
  end
end
