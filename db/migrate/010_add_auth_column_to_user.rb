class AddAuthColumnToUser < ActiveRecord::Migration

  def self.up
    add_column "users", "auth", :string, :default => 'db', :null => false

    User.reset_column_information
    User.find(:all).each do |user|
      if user.uid == 0
        user.auth = 'db'
      else
        user.auth = 'ldap'
      end
      user.save
    end
  end

  def self.down
    remove_column "users", "auth"
  end

end
