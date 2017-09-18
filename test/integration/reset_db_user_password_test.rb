# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class ResetDbUserPasswordTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper

  test 'reset bobs password' do
    account_path1 = team_group_account_path(team_id: teams(:team1).id, group_id: groups(:group1).id, id: accounts(:account1).id)
    last_teammember_team = teams(:team2)
    login_as('admin')
    post resetpassword_admin_recryptrequests_path, params: {new_password: 'test', user_id: users('bob').id},
                                                   headers: {'HTTP_REFERER' => 'where_i_came_from'}
    logout
  
    can_access_account(account_path1, 'bob', 'test','test', 'password')
    assert_not Team.exists?(last_teammember_team.id), 'last teammember team should be removed'
  end
end
