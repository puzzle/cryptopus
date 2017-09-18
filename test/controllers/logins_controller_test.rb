# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'cannot login with wrong password' do
    post :authenticate, params: { password: 'wrong_password', username: 'bob' }

    assert_match(/Authentication failed/, flash[:error])
  end

  test 'redirects to recryptrequests page if private key cannot be decrypted' do
    users(:bob).update(private_key: "invalid private_key")

    post :authenticate, params: { password: 'password', username: 'bob' }

    assert_redirected_to recryptrequests_new_ldap_password_path
  end

  test 'login logout' do
    login_as(:bob)

    get :logout

    assert_redirected_to login_login_path
  end

  test 'login logout and save jumpto if set' do
    login_as(:admin)

    get :logout, params: { jumpto: admin_users_path }

    assert_redirected_to admin_users_path
  end

  test 'cannot login with unknown username' do
    post :authenticate, params: { password: 'password', username: 'baduser' }

    assert_match(/Authentication failed/, flash[:error])
  end

  test 'cannot login without username' do
    post :authenticate, params: { password: 'password' }

    assert_match(/Authentication failed/, flash[:error])
  end

  test 'update password' do
    login_as(:bob)
    post :update_password, params: { old_password: 'password', new_password1: 'test', new_password2: 'test' }

    assert_match(/new password/, flash[:notice])
    assert_equal true, users(:bob).authenticate('test')
  end

  test 'update password, error if oldpassword not match' do
    login_as(:bob)
    post :update_password, params: { old_password: 'wrong_password', new_password1: 'test', new_password2: 'test' }

    assert_match(/Invalid user \/ password/, flash[:error])
    assert_equal false, users(:bob).authenticate('test')
  end

  test 'update password, error if new passwords not match' do
    login_as(:bob)
    post :update_password, params: { old_password: 'password', new_password1: 'test', new_password2: 'wrong_password' }

    assert_match(/equal/, flash[:error])
    assert_equal false, users(:bob).authenticate('test')
  end

  test 'redirects if ldap user tries to update password' do
    users(:bob).update_attribute(:auth, 'ldap')
    login_as(:bob)
    post :update_password, params: { old_password: 'password', new_password1: 'test', new_password2: 'test' }

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

  test 'updates last login at if user logs in' do
    time = Time.zone.now
    ActiveSupport::TimeZone.any_instance.stubs(:now).returns(time)

    post :authenticate, params: { password: 'password', username: 'bob' }

    users(:bob).reload
    assert_equal(time.to_s, users(:bob).last_login_at.to_s)
  end

  test 'shows last login datetime and ip without country' do
    user = users(:bob)
    user.update_attributes(last_login_at: '2017-01-01 16:00:00 + 0000', last_login_from: '192.168.210.10')

    post :authenticate, params: { password: 'password', username: 'bob' }
    assert_equal('The last login was on January 01, 2017 16:00 from 192.168.210.10', flash[:notice])
  end

  test 'does not show last login date if not available' do
    users(:bob).update_attribute(:last_login_at, nil)
    post :authenticate, params: { password: 'password', username: 'bob' }
    assert_nil(flash[:notice])
  end

  test 'does not show previous login ip if not available' do
    user = users(:bob)
    user.update_attributes(last_login_at: '2017-01-01 16:00:00 + 0000', last_login_from: nil)

    post :authenticate, params: { password: 'password', username: 'bob' }
    assert_equal('The last login was on January 01, 2017 16:00', flash[:notice])
  end

  test 'shows previous login ip and country' do
    user = users(:bob)
    user.update_attributes(last_login_at: '2001-09-11 19:00:00 + 0000', last_login_from: '153.123.34.34')

    post :authenticate, params: { password: 'password', username: 'bob' }
    assert_equal('The last login was on September 11, 2001 19:00 from 153.123.34.34 (JPN)', flash[:notice])
  end
end
