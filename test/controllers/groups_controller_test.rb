require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'show breadcrumb path 1 if user is on index of groups' do
    login_as (:bob)

    team1 = teams(:team1)

    get :index, team_id: team1
    assert_select '.breadcrumbs', text: 'Teams > team1'
    assert_select '.breadcrumbs', contains: '<a>Teams</a> > team1'
  end

  test 'show breadcrump path 2 if user is on edit of groups' do
    login_as (:bob)

    team1 = teams(:team1)
    group1 = groups(:group1)

    get :edit, id: group1, team_id: team1
    assert_select '.breadcrumbs', text: 'Teams > team1 > group1'
    assert_select '.breadcrumbs', contains: '<a>Teams</a> > <a>team1</a> > group1'
  end

end
