# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class AccountHandler

attr_accessor :account
attr_accessor :group
attr_accessor :private_key
attr_accessor :user_id

  def initialize(account, group, private_key, user_id)
    @account = account
    @group = group
    @private_key = private_key
    @user_id = user_id
  end


  def move
    move_account unless same_team?
    account.group_id = group.id
    account.save
  end

  private

  def move_account
    old_password = decrypt_old_team_password
    new_password = decrypt_new_team_password

    account.decrypt(old_password)
    account.group.team.id = group.team.id
    account.encrypt(new_password)
  end

  def move_items
    old_password = decrypt_old_team_password
    new_password = decrypt_new_team_password
    account.items.each do |i|
      file = CryptUtils.decrypt_blob(i.file, old_password)
      file.CryptUtils.encrypt_blob(file.read, new_password)
      i.save
    end
  end

  def same_team?
    return account.group.team == group.team
  end

  def decrypt_old_team_password
    old_teammember = account.group.team.teammember(user_id)
    CryptUtils.decrypt_team_password(old_teammember.password, private_key)
  end

  def decrypt_new_team_password
    new_teammember = group.team.teammember(user_id)
    CryptUtils.decrypt_team_password(new_teammember.password, private_key)
  end
end
