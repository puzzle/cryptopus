# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class UserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'bob logs in' do
    login_as('bob')
    assert_equal search_path, request.fullpath
  end

  test 'bob logs in with spaces in username' do
    login_as('   bob   ')
    assert_equal search_path, request.fullpath
  end

  test 'bob logs in with wrong password' do
    login_as('bob', 'wrong_password')
    assert_includes flash[:error], 'Authentication failed'
    assert_equal login_login_path, request.fullpath
  end

  test 'bob logs out manuel' do
    login_as('bob')
    get logout_login_path
    follow_redirect!
    assert_equal login_login_path, request.fullpath
  end

  test 'goto requested page after login' do
    account = accounts(:account1)
    account1_path = team_group_account_path('en',account.group.team, account.group, account)
    get account1_path
    follow_redirect!
    assert_equal login_login_path, request.fullpath
    login_as('bob')
    assert_equal account1_path, request.fullpath
  end

  test 'should reset session after login' do
    get login_login_path
    old_session_id = session.id
    login_as('bob')
    assert_not_equal old_session_id, session.id
  end
end
