class AddPersonalOwnerToTeams < ActiveRecord::Migration[6.1]
  def up
    add_column :teams, :type, :string, null: false

    Team.all.find_each do |team|
      team.update!(type: Team::Shared.sti_name)
    end

    add_column :teams, :personal_owner_id, :integer, index: { unique: true }

    User::Human.all.find_each do |user|
      user.create_personal_team!
    end
  end

  def down
    User::Human.all.find_each do |user|
      user.personal_team.destroy!
    end

    remove_column :teams, :type

    remove_column :teams, :personal_owner_id
  end
end
