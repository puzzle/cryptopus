# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AddAuthColumnToUser < ActiveRecord::Migration[4.2]

  def change
    add_column :users, :auth, :string, default: 'db', null: false

    User.reset_column_information
    User.find_each do |user|
      if user.uid == 0
        user.auth = 'db'
      else
        user.auth = 'ldap'
      end
      user.save
    end
  end

end
