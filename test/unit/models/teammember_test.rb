# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class TeammemberTest < ActiveSupport::TestCase

  test 'does not add second user in same team' do
    params = {}
    params[:user_id] = users(:alice).id
    params[:team_id] = teams(:team1).id
    teammember = Teammember.new(params)
    assert_not teammember.valid?
  end

  test 'can add second user' do
    params = {}
    params[:user_id] = users(:admin).id
    params[:team_id] = teams(:team2).id

    params2 = {}
    params2[:user_id] = users(:alice).id
    params2[:team_id] = teams(:team2).id
    teammember = Teammember.new(params)
    teammember2 = Teammember.new(params2)
    assert teammember.valid?
    assert teammember2.valid?
  end
  
  test 'can add api user' do
    api_user = user.api_users.create
    
    bobs_private_key = user.decrypt_private_key('password')
    plaintext_team_password = teams(:team1).decrypt_team_password(user, bobs_private_key)

    teams(:team1).add_user(api_user, plaintext_team_password)

    team = teams(:team1)
    team1_bob = teammembers(:team1_bob)
    assert_equal false, team1_bob.destroyed?
    assert_equal true, team.teammember?(api_user)
  end

  test 'cannot remove last teammember' do
    team = teams(:team2)
    team2_bob = teammembers(:team2_bob)

    team2_bob.destroy

    assert team2_bob.persisted?
    assert_match /Cannot remove last teammember/, team2_bob.errors[:base].first
  end

  test 'admin user cannot be removed from non private team' do
    team1_admin = teammembers(:team1_admin)

    team1_admin.destroy

    assert team1_admin.persisted?
    assert_match /Admin user cannot be removed from non private team/, team1_admin.errors[:base].first
  end

  test 'remove teammember' do
    team = teams(:team1)
    team1_bob = teammembers(:team1_bob)
    team1_bob.destroy
    assert team1_bob.destroyed?
    assert team1_bob.errors.empty?
  end
  
  test 'remove teammember and his api users from team' do
    api_user = user.api_users.create
    
    bobs_private_key = user.decrypt_private_key('password')
    plaintext_team_password = teams(:team1).decrypt_team_password(user, bobs_private_key)

    teams(:team1).add_user(api_user, plaintext_team_password)

    team = teams(:team1)
    team1_bob = teammembers(:team1_bob)
    team1_bob.destroy
    assert team1_bob.destroyed?
    assert team1_bob.errors.empty?
    assert_equal false, team.teammember?(api_user)
  end

  private

  def user
    users(:bob)
  end
end
