# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class TeamTest <  ActiveSupport::TestCase
  test 'removes all assoziated groups, accounts, teammembers if team is destroyed' do
    team1 = teams(:team1)
    account1 = accounts(:account1)
    group1 = groups(:group1)

    team1.destroy

    assert team1.destroyed?
    assert_raises(ActiveRecord::RecordNotFound) { Group.find(group1.id) }
    assert_raises(ActiveRecord::RecordNotFound) { Account.find(account1.id) }
    assert Teammember.where(team_id: team1.id).empty?
    #TODO check items also removed
  end
  test "returns teammember candidates" do
    teammembers(:team1_bob).destroy

    team = teams(:team1)
    candidates = team.member_candidates

    refute_includes candidates, users(:root)
    refute_includes candidates, users(:admin)
    refute_includes candidates, users(:alice)
    assert_includes candidates, users(:bob)
  end

  test 'root is never included in member candidates' do
    team = Team.create(users(:admin), name: 'foo', noroot: true)

    candidates = team.member_candidates

    refute_includes candidates, users(:root)
    refute_includes candidates, users(:admin)
    assert_includes candidates, users(:bob)
    assert_includes candidates, users(:alice)
  end

  test "does not add user if already teammember" do
    team = teams(:team1)
    plaintext_private_key = decrypt_private_key(alice)
    plaintext_team_pw = team.decrypt_team_password(alice, plaintext_private_key)

    exception = assert_raises do
      team.add_user(bob, plaintext_team_pw)
    end

    assert_match /user is already team member/, exception.message
  end

  test "adds user to team" do
    team = teams(:team1)
    plaintext_team_password = team.
      decrypt_team_password(bob, decrypt_private_key(bob))

    team.remove_user(alice)

    assert_difference('team.teammembers.count', 1) do
      team.add_user(alice, plaintext_team_password)
    end

    alice_plaintext_team_password = team.
      decrypt_team_password(alice, decrypt_private_key(alice))

    assert_equal plaintext_team_password, alice_plaintext_team_password
  end

  test "removes user from team" do
    team = teams(:team1)

    assert_difference('team.teammembers.count', -1) do
      team.remove_user(alice)
    end
  end

  test 'create new team adds creator, root and admins' do
    params = {}
    params[:name] = 'foo'
    params[:description] = 'foo foo'
    params[:private] = false
    params[:noroot] = false

    team = Team.create(bob, params)

    assert_equal 3, team.teammembers.count
    user_ids = team.teammembers.pluck(:user_id)
    assert_includes user_ids, bob.id
    assert_includes user_ids, users(:root).id
    assert_includes user_ids, users(:admin).id
    assert_not team.private?
    assert_not team.noroot?
    assert_equal 'foo', team.name
    assert_equal 'foo foo', team.description
  end

  test 'create new team adds creator and admins' do
    params = {}
    params[:name] = 'foo'
    params[:description] = 'foo foo'
    params[:private] = false
    params[:noroot] = true

    team = Team.create(bob, params)

    assert_equal 2, team.teammembers.count
    user_ids = team.teammembers.pluck(:user_id)
    assert_includes user_ids, bob.id
    assert_includes user_ids, users(:admin).id
    assert_not team.private?
    assert team.noroot?
    assert_equal 'foo', team.name
    assert_equal 'foo foo', team.description
  end

  test 'create new team adds creator and root' do
    params = {}
    params[:name] = 'foo'
    params[:description] = 'foo foo'
    params[:private] = true
    params[:noroot] = false

    team = Team.create(bob, params)

    assert_equal 2, team.teammembers.count
    user_ids = team.teammembers.pluck(:user_id)
    assert_includes user_ids, bob.id
    assert_includes user_ids, users(:root).id
    assert team.private?
    assert_not team.noroot?
    assert_equal 'foo', team.name
    assert_equal 'foo foo', team.description
  end

  test 'create new team adds creator only' do
    params = {}
    params[:name] = 'foo'
    params[:description] = 'foo foo'
    params[:private] = true
    params[:noroot] = true

    team = Team.create(bob, params)

    assert_equal 1, team.teammembers.count
    user_ids = team.teammembers.pluck(:user_id)
    assert_includes user_ids, bob.id
    assert team.private?
    assert team.noroot?
    assert_equal 'foo', team.name
    assert_equal 'foo foo', team.description
  end

  test 'root cannot create noroot team' do
    params = {}
    params[:name] = 'foo'
    params[:description] = 'foo foo'
    params[:private] = false
    params[:noroot] = true

    exception = assert_raises do
      team = Team.create(users(:root), params)
    end

    assert_match /root cannot create private team/, exception.message
  end

  test 'does not create team if name is empty' do
    params = {}
    params[:name] = ''
    params[:description] = 'foo foo'
    params[:private] = false
    params[:noroot] = false

    team = Team.create(bob, params)

    assert_not team.valid?
    assert_match /Name/, team.errors.full_messages.first
  end

  test 'root cannot be removed from team' do
    team = teams(:team1)

    e = assert_raises do
      team.remove_user(users(:root))
    end

    assert_equal 'root cannot be removed from team', e.message
  end

  private
  def alice
    users(:alice)
  end

  def bob
    users(:bob)
  end

  def decrypt_private_key(user)
    user.decrypt_private_key('password')
  end

end
