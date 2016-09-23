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


  def move(new_group, private_key, user_id)
    @new_group = new_group
    @private_key = private_key
    @user_id = user_id

    move_account_to_team unless same_team?

    account.group_id = new_group.id

    account.encrypt(decrypt_team_password(new_group.team))
    account.save
  end

  private

  def move_account_to_team
    move_items
    account.cleartext_password = CryptUtils.decrypt_blob(account.password, old_team_password)
    account.cleartext_username = CryptUtils.decrypt_blob(account.username, old_team_password)
    account.group.team = new_team
  end

  def move_items
    new_team_password = decrypt_team_password(new_team)
    account.items.each do |i|
      file = CryptUtils.decrypt_blob(i.file, old_team_password)
      i.file = CryptUtils.encrypt_blob(file, new_team_password)
      i.save
    end
  end

  def same_team?
    old_team == new_team
  end

  def decrypt_team_password(team)
    teammember = team.teammember(user_id)
    CryptUtils.decrypt_team_password(teammember.password, private_key)
  end

  def old_team_password
    @old_team_password ||= decrypt_team_password(old_team)
  end

  def new_team
    @new_team ||= new_group.team
  end

  def old_team
    @old_team ||= account.group.team
  end

end
