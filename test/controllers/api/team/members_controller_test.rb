# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Team::MembersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'returns team member candidates for new team' do
    login_as(:admin)
    team = Team.create(users(:admin), {name: 'foo'})

    get :candidates, params: { team_id: team }, xhr: true

    candidates = JSON.parse(response.body)['data']['user/humen']

    assert_equal 3, candidates.size
    assert candidates.any? {|c| c['label'] == 'Alice test' }, 'Alice should be candidate'
    assert candidates.any? {|c| c['label'] == 'Bob test' }, 'Bob should be candidate'
    assert candidates.any? {|c| c['label'] == 'Tux Miller' }, 'Configuration should be candidate'
  end

  test 'returns team members for given team' do
    login_as(:admin)

    team = teams(:team1)
    teammembers(:team1_bob).destroy!

    get :index, params: { team_id: team }, xhr: true

    members = JSON.parse(response.body)['data']['teammembers']

    assert_equal 3, members.size
    assert members.any? {|c| c['label'] == 'Alice test' }, 'Alice should be in team'
    assert members.any? {|c| c['label'] == 'Admin test' },  'Admin should be in team'
  end

  test 'creates new teammember for given team' do
    login_as(:admin)
    team = teams(:team1)
    user = Fabricate(:user)

    post :create, params: { team_id: team, user_id: user }, xhr: true

    assert team.teammember?(user), 'User should be added to team'
  end

  test 'does not remove admin from non private team' do
    login_as(:alice)

    assert_raise do
      delete :destroy, params: { team_id: teams(:team1), id: users(:admin) }, xhr: true
    end
  end

  test 'remove teammember from team' do
    login_as(:alice)
    assert_difference('Teammember.count', -1) do
      delete :destroy, params: { team_id: teams(:team1), id: users(:bob) }, xhr: true
    end
  end
  
  context 'api user' do
    test 'add api user to team' do
      login_as(:admin)
      team = teams(:team1)
      user = users(:api) 

      post :create, params: { team_id: team, user_id: user }, xhr: true

      assert team.teammember?(user), 'User should be added to team'
  end
  
    test 'remove api user from team' do
      login_as(:admin)
      team = teams(:team1)
      user = users(:api) 

      post :create, params: { team_id: team, user_id: user }, xhr: true

      assert_difference('Teammember.count', -1) do
        delete :destroy, params: { team_id: teams(:team1), id: user }, xhr: true
      end
    end
  end
end
