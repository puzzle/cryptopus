# frozen_string_literal: true

module Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      return teams_by_query if query.present?
      return team_by_id if team_id.present?

      teams
    end

    def query
      @params[:q]
    end

    def team_ids
      @params[:team_ids]
    end

    def teams
      @current_user.teams
    end

    def team_id
      @params[:team_id]
    end

    private

    def teams_by_query
      teams.joins(:folders).joins(folders: :accounts).where(
        'teams.name like ?
        OR folders.name like ?
        OR accounts.accountname like ?',
        "%#{query}%", "%#{query}%", "%#{query}%"
      )
    end

    def team_by_id
      teams.find(team_id)
    end
  end
end
