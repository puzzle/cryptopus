# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AccountHandler

  attr_accessor :account, :new_group, :private_key, :user_id

  def initialize(account)
    @account = account
  end


  def move(new_group, private_key, user)
    @new_group = new_group
    @private_key = private_key
    @user = user

    move_account_to_team unless same_team?

    account.group_id = new_group.id

    account.encrypt(new_group.team.decrypt_team_password(user, private_key))
    account.save
  end

  private

  def move_account_to_team
    raise "You don't have permisson to the Team" unless @user.teams.exists?(new_group.team.id)
    move_items
    account.decrypt(old_team_password)
    account.group.team = new_team
  end

  def move_items
    new_team_password = new_team.decrypt_team_password(@user, private_key)
    account.items.each do |i|
      decrypted_file = i.decrypt_file(i.file, old_team_password)
      i.file = i.encrypt_file(decrypted_file, new_team_password)
      i.save
    end
  end

  def same_team?
    old_team == new_team
  end


  def new_team_password
    @new_team_password ||= new_team.decrypt_team_password(@user, private_key)
  end

  def old_team_password
    @old_team_password ||= old_team.decrypt_team_password(@user, private_key)
  end

  def new_team
    @new_team ||= new_group.team
  end

  def old_team
    @old_team ||= account.group.team
  end

end
