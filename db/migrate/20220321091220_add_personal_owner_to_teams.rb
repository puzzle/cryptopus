class AddPersonalOwnerToTeams < ActiveRecord::Migration[6.1]
  def change
    add_column :teams, :personal_owner_id, :integer, index: { unique: true }

    User::Human.all.find_each do |user|
      user.create_personal_team!
    end
  end
end
