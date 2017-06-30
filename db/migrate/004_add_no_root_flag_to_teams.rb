# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AddNoRootFlagToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :noroot, :boolean, default: 0, null: false

    Team.reset_column_information
    Team.find_each do |team|
      team.noroot = false
      team.save
    end
  end
end
