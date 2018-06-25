class AddUserRoleConfAdmin < ActiveRecord::Migration[5.1]
  def up
    add_column :users, :role, :integer, default: 0, null: false
    User.where(admin: true).find_each do |admin|
      admin.role = :admin
      admin.save!
    end

    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, default: false, null: false
    User.where(role: :admin).find_each do |admin|
      admin.admin = true
      admin.save!
    end

    remove_column :users, :role
  end
end
