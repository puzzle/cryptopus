# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class WizardControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'display error if password fields empty' do
    User::Human.delete_all
    post :apply, params: { password: '', password_repeat: 'password' }
    assert_match /Please provide an initial password/, flash[:error]
  end

  test 'display error if passwords do not match' do
    User::Human.delete_all
    post :apply, params: { password: 'password', password_repeat: 'other_password' }
    assert_match /Passwords do not match/, flash[:error]
  end

  test 'creates initial setup and redirects to user admin page' do
    User::Human.delete_all
    post :apply, params: { password: 'password', password_repeat: 'password' }
    assert_redirected_to admin_users_path
    assert User.find_by_ldap_uid(0)
  end

  test 'cannot access wizard if already set up' do
    post :apply, params: { password: 'password', password_repeat: 'password' }
    assert_redirected_to login_login_path

    get :index
    assert_redirected_to login_login_path
  end

  test 'logged in user cannot access wizard if already set up' do
    login_as('bob')
    post :apply, params: { password: 'password', password_repeat: 'password' }
    assert_redirected_to login_login_path

    get :index
    assert_redirected_to login_login_path
  end
end
