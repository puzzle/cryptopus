# frozen_string_literal: true

module Teams
  class FilteredList < ::FilteredList

    def fetch_entries
      return teams_by_query if query.present?
      return teams_by_ids if team_ids.present? || folder_ids.present? || account_ids.present?

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

    def team_ids
      list_param(:team_ids)
    end

    def folder_ids
      list_param(:folder_ids)
    end

    def account_ids
      list_param(:account_ids)
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

    def teams_by_ids
      # This query works but it needs the params to be an Integer Array
      teams.joins(:folders).joins(folders: :accounts).where(
        'teams.id in (?) OR
        folders.id in (?) OR
        accounts.id in (?)',
        team_ids, folder_ids, account_ids
      )
    end
  end
end
