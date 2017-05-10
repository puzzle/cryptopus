# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'cannot login with wrong password' do
    post :authenticate, password: 'wrong_password', username: 'bob'

    assert_match(/Authentication failed/, flash[:error])
  end

  test 'redirects to recryptrequests page if private key cannot be decrypted' do
    users(:bob).update(private_key: "invalid private_key")

    post :authenticate, password: 'password', username: 'bob'

    assert_redirected_to recryptrequests_new_ldap_password_path
  end

  test 'login logout' do
    login_as(:bob)

    get :logout

    assert_redirected_to login_login_path
  end

  test 'login logout and save jumpto if set' do
    login_as(:admin)

    get :logout, jumpto: admin_users_path

    assert_redirected_to admin_users_path
  end

  test 'cannot login with unknown username' do
    post :authenticate, password: 'password', username: 'baduser'

    assert_match(/Authentication failed/, flash[:error])
  end

  test 'cannot login without username' do
    post :authenticate, password: 'password'

    assert_match(/Authentication failed/, flash[:error])
  end

  test 'update password' do
    login_as(:bob)
    post :update_password, old_password: 'password', new_password1: 'test', new_password2: 'test'

    assert_match(/new password/, flash[:notice])
    assert_equal true, users(:bob).authenticate('test')
  end

  test 'update password, error if oldpassword not match' do
    login_as(:bob)
    post :update_password, old_password: 'wrong_password', new_password1: 'test', new_password2: 'test'

    assert_match(/Invalid user \/ password/, flash[:error])
    assert_equal false, users(:bob).authenticate('test')
  end

  test 'update password, error if new passwords not match' do
    login_as(:bob)
    post :update_password, old_password: 'password', new_password1: 'test', new_password2: 'wrong_password'

    assert_match(/equal/, flash[:error])
    assert_equal false, users(:bob).authenticate('test')
  end

  test 'redirects if ldap user tries to update password' do
    users(:bob).update_attribute(:auth, 'ldap')
    login_as(:bob)
    post :update_password, old_password: 'password', new_password1: 'test', new_password2: 'test'

    assert_redirected_to search_path
  end

  test 'redirects if ldap user tries to access update password site' do
    users(:bob).update_attribute(:auth, 'ldap')
    login_as(:bob)
    get :show_update_password

    assert_redirected_to search_path
  end

  test 'should redirect to wizard if new setup' do
    User.delete_all

    get :login

    assert_redirected_to wizard_path
  end

  test 'should show 401 if ip address is unauthorized' do
    Authentication::SourceIpChecker.any_instance.stubs(:ip_authorized?).returns(false)

    get :login

    assert_equal 401, response.status
  end

  test 'saves ip in session if ip allowed' do
    random_ip = "#{rand(1..253)}.#{rand(254)}.#{rand(254)}.#{rand(254)}"
    Authentication::SourceIpChecker.any_instance.stubs(:ip_authorized?).returns(true)
    ActionController::TestRequest.any_instance.stubs(:remote_ip).returns(random_ip)

    get :login

    assert_equal 200, response.status
    assert_equal random_ip, session[:authorized_ip]
  end

  test 'does not authorize previously authorized source ip' do
    source_ip = '102.20.2.1'
    Authentication::SourceIpChecker.any_instance.stubs(:ip_authorized?).returns(true)
    ActionController::TestRequest.any_instance.stubs(:remote_ip).returns(source_ip)
    session[:authorized_ip] = source_ip
    session[:user_id] = users(:bob).id
    session[:private_key] = 'fookey'

    Authentication::SourceIpChecker.any_instance.expects(:previously_authorized?)
    Authentication::SourceIpChecker.any_instance.expects(:ip_authorized?).never

    get :show_update_password

    assert_equal 200, response.status
  end
end
