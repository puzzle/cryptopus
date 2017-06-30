# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.string :output
      t.string :status
      t.string :log_type
      t.integer :executer_id
      t.timestamps null: false
    end
  end
end
