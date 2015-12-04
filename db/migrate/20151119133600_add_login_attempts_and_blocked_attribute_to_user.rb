class AddLoginAttemptsAndBlockedAttributeToUser < ActiveRecord::Migration
  def change
    add_column :users, :locked, :boolean, default: false
    add_column :users, :last_failed_login_attempt_at, :datetime
    add_column :users, :failed_login_attempts, :integer, default: 0, null: false
  end
end
