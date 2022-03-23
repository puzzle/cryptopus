class AddPersonalTeamIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :personal_team_id, :integer, not_null: true
  end
end
