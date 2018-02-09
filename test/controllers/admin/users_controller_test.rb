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
    context 'admin' do
      test 'admin updates user-profile' do
        alice = users(:alice)
        update_params = { username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname',
                          password: 'new_password' }

        login_as(:admin)
        post :update, params: { id: alice, user: update_params }

        alice.reload

        assert_equal 'new_password', alice.password
        assert_equal 'new_username', alice.username
        assert_equal 'new_givenname', alice.givenname
        assert_equal 'new_surname', alice.surname
      end

      test 'admin updates conf admin-profile' do
        tux = users(:conf_admin)
        update_params = { username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname',
                          password: 'new_password' }

        login_as(:admin)
        post :update, params: { id: tux, user: update_params }

        tux.reload

        assert_equal 'new_password', tux.password
        assert_equal 'new_username', tux.username
        assert_equal 'new_username', tux.username
        assert_equal 'new_givenname', tux.givenname
      end

      test 'admin updates admin-profile' do
        admin2 = Fabricate(:admin)
        update_params = { username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname',
                          password: 'new_password' }

        login_as(:admin)
        post :update, params: { id: admin2, user: update_params }

        admin2.reload

        assert_equal 'new_password', admin2.password
        assert_equal 'new_username', admin2.username
        assert_equal 'new_username', admin2.username
        assert_equal 'new_givenname', admin2.givenname
      end

      test 'admin cannot update ldap-user-profile' do
        bob = users(:bob)
        bob.update_attribute(:auth, 'ldap')

        update_params = { password: 'new_password',
                          username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname' }

        login_as(:admin)
        post :update, params: { id: bob, user: update_params }

        bob.reload

        assert_not_equal 'new_username', bob.username
        assert_not_equal 'new_password', bob.password
        assert_not_equal 'new_givenname', bob.givenname
        assert_not_equal 'new_surname', bob.surname
        assert_match(/Ldap user cannot be updated/, flash[:error])
      end

      test 'admin can only update roots password' do
        root = users(:root)
        update_params = { password: 'new_password',
                          username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname' }

        login_as(:admin)
        post :update, params: { id: root, user: update_params }

        root.reload

        assert_equal 'new_password', root.password
        assert_equal 'root', root.username
        assert_equal 'Root', root.givenname
        assert_equal 'test', root.surname
      end
    end

    context 'conf admin' do
      test 'conf admin can only update users surname and givenname' do
        alice = users(:alice)
        update_params = { username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname',
                          password: 'new_password' }

        login_as(:tux)
        post :update, params: { id: alice, user: update_params }

        alice.reload

        assert_equal 'alice', alice.username
        assert_not_equal 'new_password', alice.password
        assert_equal 'new_givenname', alice.givenname
        assert_equal 'new_surname', alice.surname
      end

      test 'conf admin cannot update conf admin-profile' do
        conf_admin = Fabricate(:conf_admin)
        tux = users(:conf_admin)
        update_params = { username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname',
                          password: 'new_password' }

        login_as(conf_admin.username)
        post :update, params: { id: tux, user: update_params }

        tux.reload

        assert_equal 'tux', tux.username
        assert_not_equal 'new_password', tux.password
        assert_equal 'Tux', tux.givenname
        assert_equal 'Miller', tux.surname
      end

      test 'conf admin cannot update admin-profile' do
        admin = users(:admin)
        update_params = { username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname',
                          password: 'new_password' }

        login_as(:tux)
        post :update, params: { id: admin, user: update_params }

        admin.reload

        assert_equal 'admin', admin.username
        assert_not_equal 'new_password', admin.password
        assert_equal 'Admin', admin.givenname
        assert_equal 'test', admin.surname
      end

      test 'conf admin cannot update ldap-user-profile' do
        bob = users(:bob)
        bob.update_attribute(:auth, 'ldap')

        update_params = { username: 'new_username',
                          givenname: 'new_givenname',
                          surname: 'new_surname',
                          password: 'new_password' }

        login_as(:tux)
        post :update, params: { id: bob, user: update_params }

        bob.reload

        assert_not_equal 'new_username', bob.username
        assert_not_equal 'new_password', bob.password
        assert_not_equal 'new_givenname', bob.givenname
        assert_not_equal 'new_surname', bob.surname
        assert_match(/Ldap user cannot be updated/, flash[:error])
      end
      
      test 'conf admin cannot update root-profile' do
        root = users(:root)

        login_as(:tux)
        post :update, params: { id: root, user: update_params }

        root.reload

        assert_not_equal 'new_password', root.password
        assert_equal 'root', root.username
        assert_equal 'Root', root.givenname
        assert_equal 'test', root.surname
      end
    end
  end

  private

  def update_params
    { password: 'new_password',
      username: 'new_username',
      givenname: 'new_givenname',
      surname: 'new_surname' }
  end
end
