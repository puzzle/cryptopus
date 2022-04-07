class AddPersonalTeamIdToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :personal_team_id, :integer

    User::Human.all.find_each do |user|
      user.create_personal_team!
    end
  end
end
