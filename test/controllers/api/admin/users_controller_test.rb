# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Admin::UsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'admin empowers user' do
    teammembers(:team1_bob).destroy
    bob = users(:bob)

    login_as(:admin)
    patch :update_role, params: { user_id: bob, role: User::Role::ADMIN }, xhr: true

    bob.reload
    assert bob.admin?
    assert bob.teammembers.find_by(team_id: teams(:team1))
  end

  test 'admin disempowers user' do
    teammembers(:team1_bob).destroy
    bob = users(:bob)

    login_as(:admin)
    patch :update_role, params: { user_id: bob, role: User::Role::ADMIN }, xhr: true
    bob.reload
    patch :update_role, params: { user_id: bob, role: User::Role::USER }, xhr: true
    bob.reload

    assert_not bob.admin?
    assert_not bob.teammembers.find_by(team_id: teams(:team1))
  end
  
  test 'logged-in admin user cannot delete own user' do
    bob = users(:bob)
    bob.update_attribute(:role, 2)
    login_as(:bob)

    delete :destroy, params: { id: bob.id }

    assert bob.reload.persisted?
    assert_includes(errors, 'You can\'t delete your-self')
  end

  test 'non admin cannot delete another user' do
    alice = users(:alice)
    login_as(:bob)

    delete :destroy, params: { id: alice.id }

    assert alice.reload.persisted?
    assert_includes(errors, 'Access denied')
    assert_equal 403, status_code
  end

  test 'admin can delete another user' do
    bob = users(:bob)
    alice = users(:alice)
    bob.update_attribute(:role, User::Role::ADMIN)
    login_as(:bob)

    delete :destroy, params: { id: alice.id }

    assert_not User.find_by(username: 'alice')
  end

  private

  def errors
    JSON.parse(response.body)['messages']['errors']
  end

  def status_code
    JSON.parse(response.code)
  end
end
