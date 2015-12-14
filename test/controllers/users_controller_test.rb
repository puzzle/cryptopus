require 'test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'logged-in admin user cannot delete own user' do
    bob = users(:bob)
    bob.update_attribute(:admin, true)
    login_as(:bob)

    delete :destroy, id: bob.id

    assert bob.reload.persisted?

    assert_match /You can't delete your-self/, flash[:error]
  end

  test 'bob cannot delete another user' do
    bob = users(:bob)
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
    root = users(:root)
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
end
