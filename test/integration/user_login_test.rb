require 'test_helper'
class UserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'bob logs in' do
    login_as('bob')
    assert_equal(request.fullpath, teams_path)
  end

  test 'bob logs in with wrong password' do
    login_as('bob', 'wrong_password')
    assert_includes(flash[:error], 'Authentication failed')
    assert_equal(request.fullpath, '/login/authenticate')
  end
end