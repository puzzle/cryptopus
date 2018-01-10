# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  context '#unlock' do

    test 'unlock user as admin' do
      bob = users(:bob)
      bob.update_attribute(:locked, true)
      bob.update_attribute(:failed_login_attempts, 5)

      login_as(:admin)
      get :unlock, params: { id: bob.id }

      assert_not bob.reload.locked
      assert_equal 0, bob.failed_login_attempts
    end

    test 'cannot not unlock user as normal user' do
      bob = users(:bob)
      bob.update_attribute(:locked, true)
      bob.update_attribute(:failed_login_attempts, 5)

      login_as(:alice)
      get :unlock, params: { id: bob.id }

      assert bob.reload.locked
      assert_equal 5, bob.failed_login_attempts
    end

  end

  context '#update' do

    test 'admin updates user-profile' do
      alice = users(:alice)
      update_params = { username: 'new_username', givenname: 'new_givenname' }

      login_as(:admin)
      post :update, params: { id: alice, user: update_params }

      alice.reload

      assert_equal alice.username, 'new_username'
      assert_equal alice.givenname, 'new_givenname'
    end

    test 'cannot update ldap-user-profile' do
      bob = users(:bob)
      bob.update_attribute(:auth, 'ldap')

      update_params = { username: 'new_username'}

      login_as(:admin)
      post :update, params: { id: bob, user: update_params }

      bob.reload

      assert_not_equal 'new_username', bob.username
      assert_match(/Ldap user cannot be updated/, flash[:error])
    end
  end

end
