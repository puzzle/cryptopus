# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AddLoginAttemptsAndBlockedAttributeToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :locked, :boolean, default: false
    add_column :users, :last_failed_login_attempt_at, :datetime
    add_column :users, :failed_login_attempts, :integer, default: 0, null: false
  end
end
