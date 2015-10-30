require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class LoginsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'cannot login with wrong password' do
    post :authenticate, password: 'wrong_password', username: 'bob'
    assert_match /Authentication failed/, flash[:error]
  end

  test 'redirects to recryptrequests page if private key cannot be decrypted' do
      users(:bob).update(private_key: "wrong private_key")
      post :authenticate, password: 'password', username: 'bob'
      assert_redirected_to recryptrequests_path
  end

  test 'login logout' do
    login_as(:bob)
    get :logout
    assert_redirected_to login_login_path
  end

  test 'change password' do
    login_as(:bob)
    post :pwdchange, oldpassword: 'password', newpassword1: 'test', newpassword2: 'test'
    assert_match /new password/, flash[:notice]

    User.authenticate('bob', 'test')
  end

  test 'change password, error if oldpassword not match' do
    login_as(:bob)
    post :pwdchange, oldpassword: 'wrong_password', newpassword1: 'test', newpassword2: 'test'
    assert_match /Wrong password/, flash[:error]

    assert_invalid_login('bob', 'test')
  end

  test 'change password, error if new passwords not match' do
    login_as(:bob)
    post :pwdchange, oldpassword: 'password', newpassword1: 'test', newpassword2: 'wrong_password'
    assert_match /equal/, flash[:error]

    assert_invalid_login('bob', 'test')
  end

  test 'change password, error if ldap user' do
    users(:bob).update_attribute(:auth, 'ldap')
    login_as(:bob)
    post :pwdchange, oldpassword: 'password', newpassword1: 'test', newpassword2: 'test'
    assert_match /not a local user/, flash[:error]

    assert_invalid_login('bob', 'test')
  end

  test 'get pwdchange site, error if ldap user' do
    users(:bob).update_attribute(:auth, 'ldap')
    login_as(:bob)
    get :pwdchange
    assert_match /not a local user/, flash[:error]
  end

  def assert_invalid_login(username, password)
    assert_raises(Exceptions::AuthenticationFailed){
      User.authenticate(username, password)
    }
  end
=begin
  test 'cannot login with unknown username' do
    #TODO test
  end
=end
end