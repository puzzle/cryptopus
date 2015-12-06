require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class TeamsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test "admin can delete team" do
    login_as(:admin)

    assert_difference('Team.count', -1) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /deleted/, flash[:notice]
  end

  test "root can delete team" do
    login_as(:root)

    assert_difference('Team.count', -1) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /deleted/, flash[:notice]
  end

  test "user can delete team if he is last teammember" do
    login_as(:bob)

    teammembers(:team1_root).delete
    teammembers(:team1_alice).delete
    teammembers(:team1_admin).delete

    assert_difference('Team.count', -1) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /deleted/, flash[:notice]
  end

  test "user cannot delete team if not last teammember" do
    login_as(:bob)

    teammembers(:team1_root).delete
    teammembers(:team1_bob).delete
    teammembers(:team1_admin).delete
    # only alice remains as team1 member

    assert_difference('Team.count', 0) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /cannot be deleted/, flash[:error]
  end

  test "user cannot delete team if other teammembers present" do
    login_as(:bob)

    assert_difference('Team.count', 0) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /cannot be deleted/, flash[:error]
  end

end
