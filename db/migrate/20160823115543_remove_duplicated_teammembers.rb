# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class RemoveDuplicatedTeammembers < ActiveRecord::Migration
  def up
    seen = Set.new
    Teammember.all.each do |tm|
      key = [tm.user_id, tm.team_id]
      if seen.include?(key)
        tm.delete
      else
        seen.add(key)
      end
    end
  end

  def down; end
end
