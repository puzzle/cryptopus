# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AccountHandlerMove < AccountHandler

  attr_accessor :new_group

  def move(new_group)
    @new_group = new_group

    move_account_to_new_team unless move_team?

    account.group_id = new_group.id

    account.encrypt(new_team.decrypt_team_password(user, private_key))
    account.save
  end

  private

  def move_account_to_new_team
    raise "user is not member of new team" unless user.teams.exists?(new_group.team.id)
    old_team_password = old_team.decrypt_team_password(user, private_key)
    move_items(old_team_password)
    account.decrypt(old_team_password)
  end

  def move_items(old_team_password)
    new_team_password = new_team.decrypt_team_password(user, private_key)
    account.items.each do |i|
      i.decrypt(old_team_password)
      i.file = i.encrypt(new_team_password)
      i.save
    end
  end

  def move_team?
    old_team == new_team
  end

  def new_team
    @new_team ||= new_group.team
  end

  def old_team
    @old_team ||= account.group.team
  end

end
