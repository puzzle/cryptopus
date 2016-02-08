# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class TeamsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test "admin can delete team if in team" do
    login_as(:admin)

    assert_difference('Team.count', -1) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /deleted/, flash[:notice]
  end

  test "root can delete team if in team" do
    login_as(:root)

    assert_difference('Team.count', -1) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /deleted/, flash[:notice]
  end

  test "normal teammember cannot delete team" do
    login_as(:bob)

    assert_difference('Team.count', 0) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /Only admin or root/, flash[:error]
  end

  test "normal user cannot delete team if not in team" do
    login_as(:bob)

    teammembers(:team1_bob).delete

    assert_difference('Team.count', 0) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /not member/, flash[:error]
  end

  test "Admin can delete team if not in team" do
    login_as(:admin)

    teammembers(:team1_admin).delete

    assert_difference('Team.count', -1) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /deleted/, flash[:notice]
  end

  test "Root can delete team if not in team" do
    login_as(:root)

    teammembers(:team1_root).delete

    assert_difference('Team.count', -1) do
      delete :destroy, id: teams(:team1).id
    end

    assert_redirected_to teams_path
    assert_match /deleted/, flash[:notice]
  end

  test 'bob has no delete button for teams' do
    login_as(:bob)
    get :index
    assert_select "a[href='/en/teams/#{teams(:team1).id}']", false, "Delete button should not exist"
  end

  test 'admin has delete button for teams' do
    login_as(:admin)
    get :index
    assert_select "a[href='/en/teams/#{teams(:team1).id}']"
  end

  test 'root has delete button for teams' do
    login_as(:root)
    get :index
    assert_select "a[href='/en/teams/#{teams(:team1).id}']"
  end

  test "user creates new team" do
    login_as(:bob)

    team_params = {name: 'foo', private: false, noroot: false, description: 'foo foo' }

    post :create, team: team_params

    assert_redirected_to teams_path

    team = Team.find_by(name: 'foo')
    assert_equal 3, team.teammembers.count
    user_ids = team.teammembers.pluck(:user_id)
    assert_includes user_ids, users(:bob).id
    assert_includes user_ids, users(:admin).id
    assert_includes user_ids, users(:root).id
    assert_not team.private?
    assert_not team.noroot?
    assert_equal 'foo foo', team.description
  end

  test "private or noroot cannot be enabled on existing team" do
    login_as(:alice)
    team = teams(:team1)

    assert_not team.private?
    assert_not team.noroot?

    update_params = { noroot: true, private: true }

    put :update, id: team, team: update_params

    team.reload

    assert_not team.private?
    assert_not team.noroot?
  end

  test "private or noroot cannot be disabled on existing team" do
    login_as(:alice)

    team_params = {name: 'foo', private: true, noroot: true}
    team = Team.create(users(:alice), team_params) 

    update_params = { noroot: false, private: false }

    put :update, id: team, team: update_params

    team.reload

    assert team.private?
    assert team.noroot?
  end

end
