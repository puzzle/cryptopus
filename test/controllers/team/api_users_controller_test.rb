# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Team::ApiUsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  context '#index' do
    test 'user lists his api users' do
      api_user1 = bob.api_users.create
      api_user2 = bob.api_users.create
      alice.api_users.create
      team = teams(:team1)
      
      login_as(:bob)

      get :index, params: { team_id: team }, xhr: true

      api_users = JSON.parse(response.body)['data']['team/api_users']

      assert_equal 2, api_users.size
      assert_equal api_user1.username, api_users.first.values[1]
      assert_equal api_user2.username, api_users.second.values[1]
    end
  end
  
  context '#create' do
    test 'user enables api user for team' do
      api_user1 = bob.api_users.create
      api_user2 = bob.api_users.create
      team = teams(:team1)
      
      login_as(:bob)

      post :create, params: { team_id: team, id: api_user1.id }, xhr: true

      assert_equal true, team.teammember?(api_user1)
      assert_equal false, team.teammember?(api_user2)
    end
  end
  
  context '#destroy' do
    test 'user disables api user for team' do
      api_user = bob.api_users.create
      team = teams(:team1)
      plainttext_team_password = team.decrypt_team_password(bob, bobs_private_key)
      
      login_as(:bob)

      team.add_user(api_user, plainttext_team_password)

      delete :destroy, params: { team_id: team, id: api_user.id }, xhr: true

      assert_equal false, team.teammember?(api_user)
    end
  end
    
  private

  def bob
    users(:bob)
  end

  def bobs_private_key
    bob.decrypt_private_key('password')
  end

  def alice
    users(:alice)
  end
end
