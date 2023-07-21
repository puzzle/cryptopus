# frozen_string_literal: true

module ::Teams
  class PgSearching < SearchStrategy
    def search(query, teams)
      # Get allowed entities which user is allowed to read
      allowed_folders = Folder.where(team_id: teams)
      allowed_encryptables = Encryptable.where(folder_id: allowed_folders)

      # Get matching ids with pg_search
      matching_team_ids = teams.search_by_name(query).pluck :id
      matching_folder_ids = Folder.where({ id: allowed_folders }).search_by_name(query).pluck :id
      matching_encryptable_ids = Encryptable.where({ id: allowed_encryptables }).search_by_name(query).pluck :id

      # Join allowed tables together and return matching ones
      binding.pry
      teams.where('encryptables.id IN (:encryptable_ids) OR teams.id IN (:team_ids) OR folders.id IN (:folder_ids)',
                           encryptable_ids: matching_encryptable_ids, team_ids: matching_team_ids, folder_ids: matching_folder_ids)
                    .references(:folders,
                                folders: [:encryptables])
    end
  end
end