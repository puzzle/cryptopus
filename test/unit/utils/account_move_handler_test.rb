# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountMoveHandlerTest < ActiveSupport::TestCase

  test 'Move account to a group where accountname already exist' do
    account = accounts(:account1)
    bob = users(:bob)
    private_key = decrypt_private_key(bob)
    new_group = groups(:group2)
    team_password = new_group.team.teammembers.find_by(user_id: bob.id).password
    Fabricate(:account, group: new_group, team_password: team_password, accountname: 'account1')

    account_handler = AccountMoveHandler.new(account, private_key, bob)

    assert_nil account_handler.move(new_group)
  end

  test 'Move account to a group from another team' do
    account = accounts(:account2)
    bob = users(:bob)
    private_key = decrypt_private_key(bob)
    new_group = groups(:group1)

    assert_equal account.group_id, groups(:group2).id
    account_handler = AccountMoveHandler.new(account, private_key, bob)
    account_handler.move(new_group)
    account.reload

    assert_equal 'password', account.decrypt(new_group.team.decrypt_team_password(bob, private_key))
    assert_equal account.group_id, new_group.id
  end

  test 'Move account with items to new team' do
    account = accounts(:account1)
    bob = users(:bob)
    private_key = decrypt_private_key(bob)
    new_group = groups(:group2)
    new_team_password = new_group.team.decrypt_team_password(bob, private_key)

    account_handler = AccountMoveHandler.new(account, private_key, bob)
    account_handler.move(new_group)

    assert_equal items(:item2).account, account
    assert_equal items(:item2).account.group.team, teams(:team2)

    decrypted_file_item1 = items(:item1).decrypt(new_team_password)
    decrypted_file_item2 = items(:item2).decrypt(new_team_password)

    assert_equal "Das ist ein test File", decrypted_file_item1
    assert_equal "Das ist ein test File", decrypted_file_item2
  end

  test 'Alice want to move an account to a team shes not member of' do
    alice = users(:alice)
    private_key = decrypt_private_key(alice)
    account = accounts(:account1)
    new_group = groups(:group2)

    assert_raise "user is not member of the team" do
      account_handler = AccountMoveHandler.new(account, private_key, alice)
      account_handler.move(new_group)
    end
  end

  test 'Move account to group from same team' do
    account = accounts(:account1)
    bob = users(:bob)
    private_key = decrypt_private_key(bob)
    new_group = Fabricate(:group, name: "group3", team_id: teams(:team1).id)

    account_handler = AccountMoveHandler.new(account, private_key, bob)
    account_handler.move(new_group)

    assert_equal 'password', account.decrypt(new_group.team.decrypt_team_password(bob, private_key))
    assert_equal new_group, account.group
  end

  test 'Move is rolled back if account can not be moved' do
    account = accounts(:account1)
    team1 = teams(:team1)
    bob = users(:bob)
    bobs_private_key = decrypt_private_key(bob)
    new_group = groups(:group2)
    item1 = items(:item1)
    item2 = items(:item2)

    account.expects(:save!).raises

    account_handler = AccountMoveHandler.new(account, bobs_private_key, bob)
    begin
      account_handler.move(new_group)
    rescue
      team1_password = team1.decrypt_team_password(bob, bobs_private_key)
      item1.reload.decrypt(team1_password)
      assert_equal "Das ist ein test File", item1.cleartext_file
      item2.reload.decrypt(team1_password)
      assert_equal "Das ist ein test File", item2.cleartext_file

      assert_equal team1, account.reload.group.team
    end

  end

end
