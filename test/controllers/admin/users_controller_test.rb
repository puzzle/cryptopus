# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'admin cannot delete root' do
    root = users(:root)
    login_as(:admin)
    delete :destroy, id: root

    assert root.reload.persisted?

    assert_match /Root cannot be deleted/, flash[:error]
  end

  test 'logged-in admin user cannot delete own user' do
    bob = users(:bob)
    bob.update_attribute(:admin, true)
    login_as(:bob)

    delete :destroy, id: bob.id

    assert bob.reload.persisted?

    assert_match /You can't delete your-self/, flash[:error]
  end

  test 'bob cannot delete another user' do
    alice = users(:alice)
    login_as(:bob)

    delete :destroy, id: alice.id

    assert alice.reload.persisted?
    assert_match /Access denied/, flash[:error]
  end

  test 'admin can delete another user' do
    bob = users(:bob)
    alice = users(:alice)
    bob.update_attribute(:admin, true)
    login_as(:bob)

    delete :destroy, id: alice.id

    assert_not User.find_by(username: 'alice')
  end

  test 'root can delete another user' do
    alice = users(:alice)
    login_as(:root)

    delete :destroy, id: alice.id

    assert_not User.find_by(username: 'alice')
  end

  test 'unlock user as admin' do
    bob = users(:bob)
    bob.update_attribute(:locked, true)
    bob.update_attribute(:failed_login_attempts, 5)

    login_as(:root)
    get :unlock, id: bob.id

    assert_not bob.reload.locked
    assert_equal 0, bob.failed_login_attempts
  end

  test 'could not unlock user as normal user' do
    bob = users(:bob)
    bob.update_attribute(:locked, true)
    bob.update_attribute(:failed_login_attempts, 5)

    login_as(:alice)
    get :unlock, id: bob.id

    assert bob.reload.locked
    assert_equal 5, bob.failed_login_attempts
  end

  test 'admin updates user-profile' do
    alice = users(:alice)
    update_params = { username: 'new_username', givenname: 'new_givenname' }

    login_as(:admin)
    post :update, id: alice, user: update_params

    alice.reload

    assert_equal alice.username, 'new_username'
    assert_equal alice.givenname, 'new_givenname'
  end

  test 'root updates user-profile' do
    bob = users(:bob)
    update_params = { username: 'new_username', givenname: 'new_givenname' }

    login_as(:root)
    post :update, id: bob, user: update_params

    bob.reload

    assert_equal bob.username, 'new_username'
    assert_equal bob.givenname, 'new_givenname'
  end

  test 'cannot update root-profile' do
    root = users(:root)
    update_params = { username: 'new_username'}

    login_as(:admin)
    post :update, id: root, user: update_params

    root.reload

    assert_not_equal 'new_username', root.username
    assert_match /Root cannot be updated/, flash[:error]
  end

  test 'cannot update ldap-user-profile' do
    bob = users(:bob)
    bob.update_attribute(:auth, 'ldap')

    update_params = { username: 'new_username'}

    login_as(:admin)
    post :update, id: bob, user: update_params

    bob.reload

    assert_not_equal 'new_username', bob.username
    assert_match /Ldap user cannot be updated/, flash[:error]
  end

  test 'root empowers user to admin' do
    teammembers(:team1_bob).destroy
    bob = users(:bob)
    update_params = { admin: true }

    login_as(:root)
    post :update_admin, id: bob, user: update_params

    bob.reload

    login_as(:bob)

    assert bob.admin?
    assert bob.teammembers.find_by(team_id: teams(:team1))
  end

  test 'root disempowers admin' do
    admin = users(:admin)
    update_params = { admin: false }

    login_as(:root)
    post :update_admin, id: admin, user: update_params

    admin.reload

    assert_not admin.admin?
    assert_not admin.teammembers.find_by(team_id: teams(:team1))
  end
end
