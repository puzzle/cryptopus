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
      test 'admin updates users attributes' do
        alice = users(:alice)

        login_as(:admin)
        post :update, params: { id: alice, user_human: update_params }

        alice.reload

        assert_equal 'new_username', alice.username
        assert_equal 'new_givenname', alice.givenname
        assert_equal 'new_surname', alice.surname
      end

      test 'admin updates conf admins attributes' do
        tux = users(:conf_admin)

        login_as(:admin)
        post :update, params: { id: tux, user_human: update_params }

        tux.reload

        assert_equal 'new_username', tux.username
        assert_equal 'new_username', tux.username
        assert_equal 'new_givenname', tux.givenname
      end

      test 'admin updates admins attributes' do
        admin2 = Fabricate(:admin)

        login_as(:admin)
        post :update, params: { id: admin2, user_human: update_params }

        admin2.reload

        assert_equal 'new_username', admin2.username
        assert_equal 'new_username', admin2.username
        assert_equal 'new_givenname', admin2.givenname
      end

      test 'admin cannot update ldap-users attributes' do
        bob = users(:bob)
        bob.update_attribute(:auth, 'ldap')

        login_as(:admin)
        post :update, params: { id: bob, user_human: update_params }

        bob.reload

        assert_not_equal 'new_username', bob.username
        assert_not_equal 'new_givenname', bob.givenname
        assert_not_equal 'new_surname', bob.surname
        assert_match(/Ldap user cannot be updated/, flash[:error])
      end

      test 'admin cannot update roots attributes' do
        root = users(:root)

        login_as(:admin)
        post :update, params: { id: root, user_human: update_params }

        root.reload

        assert_equal 'root', root.username
        assert_equal 'Root', root.givenname
        assert_equal 'test', root.surname
        assert_match(/Access denied/, flash[:error])
      end
    end

    context 'conf admin' do
      test 'conf admin can only update users surname and givenname' do
        alice = users(:alice)

        login_as(:tux)
        post :update, params: { id: alice, user_human: update_params }

        alice.reload

        assert_equal 'alice', alice.username
        assert_equal 'new_givenname', alice.givenname
        assert_equal 'new_surname', alice.surname
      end

      test 'conf admin cannot update conf admins attributes' do
        conf_admin = Fabricate(:conf_admin)
        tux = users(:conf_admin)

        login_as(conf_admin.username)
        post :update, params: { id: tux, user_human: update_params }

        tux.reload

        assert_equal 'tux', tux.username
        assert_equal 'Tux', tux.givenname
        assert_equal 'Miller', tux.surname
        assert_match(/Access denied/, flash[:error])
      end

      test 'conf admin cannot update admins attributes' do
        admin = users(:admin)

        login_as(:tux)
        post :update, params: { id: admin, user_human: update_params }

        admin.reload

        assert_equal 'admin', admin.username
        assert_equal 'Admin', admin.givenname
        assert_equal 'test', admin.surname
        assert_match(/Access denied/, flash[:error])
      end

      test 'conf admin cannot update ldap-users attributes' do
        bob = users(:bob)
        bob.update_attribute(:auth, 'ldap')

        login_as(:tux)
        post :update, params: { id: bob, user_human: update_params }

        bob.reload

        assert_not_equal 'new_username', bob.username
        assert_not_equal 'new_givenname', bob.givenname
        assert_not_equal 'new_surname', bob.surname
        assert_match(/Ldap user cannot be updated/, flash[:error])
      end
      
      test 'conf admin cannot update roots attributes' do
        root = users(:root)

        login_as(:tux)
        post :update, params: { id: root, user_human: update_params }

        root.reload

        assert_equal 'root', root.username
        assert_equal 'Root', root.givenname
        assert_equal 'test', root.surname
        assert_match(/Access denied/, flash[:error])
      end
    end
  end

  private

  def update_params
    { username: 'new_username',
      givenname: 'new_givenname',
      surname: 'new_surname' }
  end
end
