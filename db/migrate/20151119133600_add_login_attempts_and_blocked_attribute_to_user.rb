class AddLoginAttemptsAndBlockedAttributeToUser < ActiveRecord::Migration
  class << self
    def up
      add_column :users, :locked, :boolean
      add_column :users, :last_failed_login_attempt_at, :datetime
      add_column :users, :login_attempts, :integer, default: 0, null: false
    end

    def down
      remove_column :users, :locked
      remove_column :users, :last_failed_login_attempt_at
      remove_column :users, :login_attempts
    end
  end
end
