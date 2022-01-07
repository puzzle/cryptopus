# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AccountMoveHandler < AccountHandler

  attr_accessor :new_folder

  def move
    ApplicationRecord.transaction do
      move_account_to_new_team unless same_team?

      raise ActiveRecord::Rollback unless account.valid?
    end
  end

  private

  def move_account_to_new_team
    raise 'user is not member of new team' unless new_team.teammember?(user.id)

    old_team_password = old_team.decrypt_team_password(user, private_key)
    move_file_entries(old_team_password)
    account.encrypt(new_team.decrypt_team_password(user, private_key))
  end

  def move_file_entries(old_team_password)
    new_team_password = new_team.decrypt_team_password(user, private_key)
    account.file_entries.each do |i|
      i.decrypt(old_team_password)
      i.file = i.encrypt(new_team_password)
      i.save!
    end
  end

  def same_team?
    old_team == new_team
  end

  def new_team
    @new_team ||= account.folder.team
  end

  def old_team
    @old_team ||= Folder.find(account.folder_id_was).team
  end
end
