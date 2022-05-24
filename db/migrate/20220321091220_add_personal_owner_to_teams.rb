# frozen_string_literal: true

class AddPersonalOwnerToTeams < ActiveRecord::Migration[6.1]
  def up
    add_column :teams, :type, :string, null: false

    execute "UPDATE teams SET type = 'Team::Shared'"

    add_column :teams, :personal_owner_id, :integer, index: { unique: true }

    User::Human.all.find_each do |user|
      user.create_personal_team!
    end
  end

  def down
    remove_column :teams, :type

    remove_column :teams, :personal_owner_id
  end
end
