# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AddAdminFlagToTeammembers < ActiveRecord::Migration[4.2]
  def change
    add_column :teammembers, :admin, :boolean, default: 0, null: false

    root = User.unscoped.find_by_uid('0')

    unless root.nil?
      Teammember.reset_column_information
      teammembers = Teammember.find_all_by_user_id(root.id)

      teammembers.each do |teammember|
        teammember.admin = true
        teammember.save
      end
    end
  end
end
