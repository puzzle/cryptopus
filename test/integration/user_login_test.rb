require 'test_helper'
class UserLoginTest < ActionDispatch::IntegrationTest

  test 'bob logs in' do
    login_as('bob')
    assert_equal(request.fullpath, '/teams')
  end

  test 'bob logs in with wrong password' do
    login_as('bob', 'wrong_password')
    assert_includes(flash[:error], 'Authentication failed')
    assert_equal(request.fullpath, '/login/authenticate')
  end

  test 'unknown user logs in' do
    LdapTools.stubs(:ldap_login).returns(false)
    login_as('unknown_user')
    assert_includes(flash[:error], 'Authentication failed')
    assert_equal(request.fullpath, '/login/authenticate')
  end
end