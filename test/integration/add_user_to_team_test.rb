# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AddUserToTeamTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper
  test 'bob adds alice to team' do
    teammembers(:team1_alice).destroy

    account_path = team_group_account_path(team_id: teams(:team1).id, group_id: groups(:group1).id, id: accounts(:account1).id)
    cannot_access_account(account_path, 'alice')

    login_as('bob')
    add_user_to_team_path = team_teammembers_path(teams(:team1).id)
    post add_user_to_team_path, username: 'alice', commit: 'Add'
    logout

    can_access_account(account_path, 'alice', 'password','test', 'password')
  end
end