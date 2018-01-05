# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class ExtendRecryptrequests < ActiveRecord::Migration[4.2]

  def change
    add_column :recryptrequests, :adminrequired, :boolean, default: 1, null: false
    add_column :recryptrequests, :rootrequired, :boolean, default: 1, null: false

    add_column :teammembers, :locked, :boolean, default: 0, null: false
  end

end
