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
    account_path2 = team_group_account_path(team_id: teams(:team2).id, group_id: groups(:group2).id, id: accounts(:account2).id)

    login_as('admin')
    post resetpassword_admin_recryptrequests_path, {new_password: 'test', user_id: users('bob').id}, {'HTTP_REFERER' => 'where_i_came_from'}
    logout

    can_access_account(account_path1, 'bob', 'test','test', 'password')
    # TODO fix recryptrequest bug
    cannot_access_account(account_path2, 'bob', 'test')
  end
end
