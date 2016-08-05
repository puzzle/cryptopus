# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountHandlerTest < ActiveSupport::TestCase

  test 'Bob moves account to an other group' do
    account = accounts(:account1)
    bob = users(:bob)
    team1 = teams(:team1)
    private_key = decrypt_private_key(bob)


    new_group = Fabricate(:group, team: team1)

    account_handler = AccountHandler.new(account, new_group, private_key, bob.id)
    account_handler.move

    team_password = team1.decrypt_team_password(bob, private_key)
    account.decrypt(team_password)

    assert_equal new_group, account.group
    assert_equal 'test', account.cleartext_username
  end

  test 'Bob moves account to a group of an other team' do
    account = accounts(:account1)
    bob = users(:bob)
    team2 = teams(:team2)
    private_key = decrypt_private_key(bob)


    new_group = Fabricate(:group, team: team2)
    account_handler = AccountHandler.new(account, new_group, private_key, bob.id)
    account_handler.move

    team_password = team2.decrypt_team_password(bob, private_key)
    account.decrypt(team_password)

    assert_equal new_group, account.group
    assert_equal 'test', account.cleartext_username
  end

  test 'Alice want to move an account to a team shes not member of' do
    account = accounts(:account1)
    alice = users(:alice)
    team2 = teams(:team2)
    private_key = decrypt_private_key(alice)

    new_group = Fabricate(:group, team: team2)
    assert_raise NoMethodError do
      account_handler = AccountHandler.new(account, new_group, private_key, alice.id)
      account_handler.move
    team_password = team2.decrypt_team_password(alice, private_key)
    account.decrypt(team_password)
    end
  end
end
