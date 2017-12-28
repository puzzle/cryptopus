# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class RailsDefaultTimeStamps < ActiveRecord::Migration[4.2]
  def change

    %I(teams groups accounts items teammembers).each do |t|
      if column_exists?(t, :created_on)
        rename_column t, :created_on, :created_at
        rename_column t, :updated_on, :updated_at
      end
    end

  end
end
