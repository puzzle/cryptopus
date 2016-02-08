# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AddLastLoginTime < ActiveRecord::Migration

  def self.up
    add_column "users", "last_login_at", :datetime
  end

  def self.down
    remove_column "users", "last_login_at"
  end

end
