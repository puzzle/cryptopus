# frozen_string_literal: true

module ::Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      filtered_teams = teams

      filtered_teams = filter_by_favourite if favourite.present? && true?(favourite)
      filtered_teams = filter_by_query(filtered_teams) if query_present?
      filtered_teams = filter_by_id if team_id.present?
      filtered_teams = filter_by_last_teammember if only_teammember_user.present?

      filtered_teams
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

    def only_teammember_user
      User.find(@params[:only_teammember_user_id]) if @params[:only_teammember_user_id]
    end

    def teams
      @current_user.teams
                   .includes(:user_favourite_teams, :folders, folders: [:encryptables])
                   .limit(limit)
    end

    def team_id
      @params[:team_id]
    end

    def limit
      @params[:limit]
    end

    def filter_by_query(teams)
      teams.includes(:folders, folders: [:encryptables]).where(
        'lower(encryptables.description) LIKE :query
        OR lower(encryptables.name) LIKE :query
        OR lower(folders.name) LIKE :query
        OR lower(teams.name) LIKE :query',
        query: "%#{query}%"
      )
           .references(:folders,
                       folders: [:encryptables])
    end

    def filter_by_id
      [Team.find(team_id)]
    end

    def filter_by_favourite
      @current_user.favourite_teams
    end

    def filter_by_last_teammember
      only_teammember_user.only_teammember_teams
    end
  end
end
