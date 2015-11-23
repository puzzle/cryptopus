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

  test 'cannot login with unknown username' do
    post :authenticate, password: 'wrong_password', username: 'unknown_username'
    assert_match /Authentication failed/, flash[:error]
  end

  test 'update password' do
    login_as(:bob)
    post :update_password, old_password: 'password', new_password1: 'test', new_password2: 'test'
    assert_match /new password/, flash[:notice]

    users(:bob).authenticate('test')
  end

  test 'update password, error if oldpassword not match' do
    login_as(:bob)
    post :update_password, old_password: 'wrong_password', new_password1: 'test', new_password2: 'test'
    assert_match /Wrong password/, flash[:error]

    assert_not(users(:bob).authenticate('test'))
  end

  test 'update password, error if new passwords not match' do
    login_as(:bob)
    post :update_password, old_password: 'password', new_password1: 'test', new_password2: 'wrong_password'
    assert_match /equal/, flash[:error]

    assert_not(users(:bob).authenticate('test'))
  end

  test 'redirects if ldap user tries to access update password' do
    users(:bob).update_attribute(:auth, 'ldap')
    login_as(:bob)
    post :update_password, old_password: 'password', new_password1: 'test', new_password2: 'test'
    assert_redirected_to search_path

    assert_not(users(:bob).authenticate('test'))
  end

  test 'redirects if ldap user tries to access show update password site' do
    users(:bob).update_attribute(:auth, 'ldap')
    login_as(:bob)
    get :show_update_password
    assert_redirected_to search_path
  end
end
