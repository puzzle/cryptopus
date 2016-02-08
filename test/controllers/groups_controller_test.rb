require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'show breadcrumb path 1 if user is on index of groups' do
    login_as (:bob)
# require 'pry';binding.pry
    team1 = teams(:team1)

    get :index, team_id: team1
    assert_select '.breadcrumb', text: 'Teamsteam1'
    assert_select '.breadcrumb a', count: 1
    assert_select '.breadcrumb a', text: 'Teams'
    assert_select '.breadcrumb a', text: 'team1', count: 0

  end

  test 'show breadcrump path 2 if user is on edit of groups' do
    login_as (:bob)

    team1 = teams(:team1)
    group1 = groups(:group1)

    get :edit, id: group1, team_id: team1
    assert_select '.breadcrumb', text: 'Teamsteam1group1'
    assert_select '.breadcrumb a', count: 2
    assert_select '.breadcrumb a', text: 'Teams'
    assert_select '.breadcrumb a', text: 'team1'
    assert_select '.breadcrumb a', text: 'group1', count: 0
    end

end
