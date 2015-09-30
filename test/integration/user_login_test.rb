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
    assert_equal authenticate_login_path, request.fullpath
  end

  test 'bob logs out manuel' do
    login_as('bob')
    get_via_redirect logout_login_path
    assert_equal login_login_path, request.fullpath
  end

  test 'goto requested page after login' do
    account = accounts(:account1)
    account1_path = team_group_account_path(account.group.team, account.group, account)
    get_via_redirect account1_path
    assert_equal login_login_path, request.fullpath
    login_as('bob')
    assert_equal account1_path, request.fullpath
  end
end