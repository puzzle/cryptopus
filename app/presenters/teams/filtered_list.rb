# frozen_string_literal: true

module Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      if query.present?
        return teams.where('name like ?', "%#{query}%")
      end

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
  end
end
