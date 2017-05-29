class AddLastLoginFromToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_login_from, :string
  end
end
