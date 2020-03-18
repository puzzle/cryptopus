# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AddUserToTeamTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper
  test 'bob adds alice to team' do
    GeoIp.expects(:activated?).returns(false).at_least_once
    teammembers(:team1_alice).destroy

    account = accounts(:account1)
    account_path = account_path(account.id)
    cannot_access_account(account_path, 'alice')

    login_as('bob')
    path = team_members_path(team_id: teams(:team1))
    post path, params: { user_id: users(:alice).id }, xhr: true
    logout

    can_access_account(account_path, 'alice', 'password','test', 'password')
  end
end
