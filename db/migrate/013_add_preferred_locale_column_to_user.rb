# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AddPreferredLocaleColumnToUser < ActiveRecord::Migration

  def self.up
    add_column "users", "preferred_locale", :string, :default => 'en', :null => false

    User.reset_column_information
    
    User.all.each do |user|
      user.preferred_locale = 'en'
      user.save
    end
  end

  def self.down
    remove_column "users", "preferred_locale"
  end

end
