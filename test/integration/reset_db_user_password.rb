# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class ResetDbUserPassword < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper

  test 'reset bobs password' do
    account_path = team_group_account_path(team_id: teams(:team1).id, group_id: groups(:group1).id, id: accounts(:account1).id)

    login_as('admin')
    post resetpassword_admin_recryptrequests_path, {new_password: 'test', user_id: users('bob').id}, {'HTTP_REFERER' => '/babies/new'}
    logout

    can_access_account(account_path, 'bob', 'test','test', 'password')
  end
end