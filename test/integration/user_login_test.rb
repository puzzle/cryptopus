require 'test_helper'
class UserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'bob logs in' do
    login_as('bob')
    assert_equal teams_path, request.fullpath
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
end