require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class TeamsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper
  test "should remove account if admin" do
    admin = users(:admin)
    login_as(:admin)
    delete :destroy, id: teams(:team1).id
    assert_match /deleted/, flash[:notice]
  end

  test "should remove account if root" do
    root = users(:root)
    login_as(:root)
    delete :destroy, id: teams(:team1).id
    assert_match /deleted/, flash[:notice]
  end

  test "should remove account if last teammember" do
    bob = users(:bob)
    login_as(:bob)

    teammembers(:team1_root).delete
    teammembers(:team1_alice).delete
    teammembers(:team1_admin).delete

    delete :destroy, id: teams(:team1).id
    assert_match /deleted/, flash[:notice]
  end

  test "should not remove account" do
    bob = users(:bob)
    login_as(:bob)

    delete :destroy, id: teams(:team1).id
    assert_match /cannot delete/, flash[:error]
  end
end