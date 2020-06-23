# frozen_string_literal: true

module Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      return filter_by_query if query.present?
      return filter_by_id if team_id.present?

      teams
    end

    private

    def query
      @params[:q]
    end

    def teams
      @current_user.teams
    end

    def team_id
      @params[:team_id]
    end

    def filter_by_query
      teams.includes(:folders, folders: [:accounts]).where('lower(teams.name) LIKE :query
        OR lower(folders.name) LIKE :query
        OR lower(accounts.accountname) LIKE :query',
        query: "%#{query.downcase}%").references(:folders, folders: [:accounts])
    end

    def filter_by_id
      [Team.find(team_id)]
    end
  end
end
