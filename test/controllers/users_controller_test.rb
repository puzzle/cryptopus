require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

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

  test 'admin can delete another user' do
    bob = users(:bob)
    alice = users(:alice)
    bob.update_attribute(:admin, true)
    login_as(:bob)

    delete :destroy, id: alice.id

    # TODO check alice was deleted

  end
end
