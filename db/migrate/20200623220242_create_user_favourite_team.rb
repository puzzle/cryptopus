class CreateUserFavouriteTeam < ActiveRecord::Migration[6.0]
  def change
    create_table :user_favourite_teams do |t|
      t.integer :team_id, default: 0,  null: false
      t.integer :user_id, default: 0,  null: false
      t.timestamps
    end
  end
end
