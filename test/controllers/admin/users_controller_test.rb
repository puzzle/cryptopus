# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  context '#destroy' do

    test 'logged-in admin user cannot delete own user' do
      admin = users(:admin)
      login_as(:admin)

      assert_difference('User.count', 0) do
        delete :destroy, params: { id: admin.id }
      end

      assert admin.reload.persisted?

      assert_match /You can't delete your-self/, flash[:error]
    end

    test 'bob cannot delete another user' do
      alice = users(:alice)
      login_as(:bob)

      assert_difference('User.count', 0) do
        delete :destroy, params: { id: alice.id }
      end

      assert alice.reload.persisted?
      assert_match /Access denied/, flash[:error]
    end

    test 'admin can delete another user' do
      alice = users(:alice)
      login_as(:admin)

      assert_difference('User.count', -1) do
        delete :destroy, params: { id: alice.id }
      end

      assert_not User.find_by(username: 'alice')
    end

    test 'admin can delete another admin' do
      admin2 = Fabricate(:admin)
      login_as(:admin)

      assert_difference('User.count', -1) do
        delete :destroy, params: { id: admin2.id }
      end

      assert_not User.find_by(username: admin2.username)
    end
  end

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

      assert_equal 'new_username', alice.username
      assert_equal 'new_givenname', alice.givenname
    end

    test 'admin updates ldap-user-username' do
      alice = users(:alice)
      alice.update_attribute(:auth, 'ldap')
      update_params = { username: 'new_username' }

      login_as(:admin)
      post :update, params: { id: alice, user: update_params }

      alice.reload

      assert_equal 'new_username', alice.username
    end
    
    test 'admin cannot update ldap-user-givenname' do
      alice = users(:alice)
      alice.update_attribute(:auth, 'ldap')
      update_params = { givenname: 'new_givenname' }

      login_as(:admin)
      post :update, params: { id: alice, user: update_params }

      alice.reload

      assert_equal 'Alice', alice.givenname
    end
    
    test 'admin cannot update ldap-user-surname' do
      alice = users(:alice)
      alice.update_attribute(:auth, 'ldap')
      update_params = { surname: 'new_surname' }

      login_as(:admin)
      post :update, params: { id: alice, user: update_params }

      alice.reload

      assert_equal 'test', alice.surname
    end

  end

end
