# encoding: utf-8

#  Copyright (c) 2008-2018, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Team::ApiUserTest < ActiveSupport::TestCase
  
  context '#list' do
    test 'user lists his api_users' do
      api_user
      api_user
      alice.api_users.create
      api_users = Team::ApiUser.list(bob, team)

      assert_equal 2, api_users.count
    end
  end
  
  context '#enable' do
    test 'enable api user for team' do
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      team_api_user = Team::ApiUser.new(api_user, team)
      team_api_user.enable(plaintext_team_password)

      assert_equal true, team_api_user.enabled?
    end
  end
  
  context '#disable' do
    test 'disable api user for team ' do
      plaintext_team_password = team.decrypt_team_password(bob, bobs_private_key)

      team_api_user = Team::ApiUser.new(api_user, team)
      team_api_user.enable(plaintext_team_password)
      team_api_user.disable

      assert_equal false, team_api_user.enabled?
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

  def team
    teams(:team1)
  end

  def api_user
    bob.api_users.create
  end
end
