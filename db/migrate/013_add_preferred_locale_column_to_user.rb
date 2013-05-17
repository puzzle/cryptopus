class AddPreferredLocaleColumnToUser < ActiveRecord::Migration

  def self.up
    add_column "users", "preferred_locale", :string, :default => 'en', :null => false

    User.reset_column_information
    
    User.find(:all).each do |user|
      user.preferred_locale = 'en'
      user.save
    end
  end

  def self.down
    remove_column "users", "preferred_locale"
  end

end
