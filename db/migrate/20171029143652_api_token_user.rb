class ApiTokenUser < ActiveRecord::Migration[5.1]

  def up
    add_column :users, :type, :string
    add_column :users, :human_user_id, :integer
    add_column :users, :options, :text

    update_human_users
  end

  def down
    remove_column :users, :type
    remove_column :users, :human_user_id
    remove_column :users, :options
  end

  private

  def update_human_users
    User.where(type: nil).find_each do |u|
      u.update!(type: User::Human)
    end
  end

end
