# frozen_string_literal: true

module ::Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      if only_teammember_user.present?
        filtered_teams = filter_by_last_teammember
      else
        filtered_teams = teams

        filtered_teams = SearchStrategy.new.search(query, filtered_teams) if query_present?
        filtered_teams = filter_by_id(filtered_teams) if team_id.present?
      end

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
      teams = if true?(favourite)
                @current_user.favourite_teams
              else
                @current_user.teams
              end
      teams.includes(*team_includes)
    end

    def team_includes
      if team_id || query_present?
        [:user_favourite_teams, { folders: { encryptables: :sender } }]
      else
        [:user_favourite_teams, :folders]
      end
    end

    def team_id
      @params[:team_id]
    end

    def limit
      @params[:limit]
    end

    def filter_by_id(filtered_teams)
      filtered_teams.where(id: team_id)
    end

    def filter_by_favourite
      @current_user.favourite_teams
    end

    def filter_by_last_teammember
      only_teammember_user.only_teammember_teams
    end
  end
end
