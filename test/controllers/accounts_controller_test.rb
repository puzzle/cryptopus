require 'test_helper'

class AccountsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'move account from one group to another' do
    login_as (:bob)

    account1 = accounts(:account1)
    group1 = groups(:group1)
    team1 = teams(:team1)
    group2 = team1.groups.new(id: '12', name: 'Test', description: 'group_description')

    patch :update, id: account1, group_id: group1, team_id: team1, account: {group_id: group2}
    account1.reload

    assert_equal account1.group_id, group2.id
  end

  test 'show breadcrumb path 1 if user is on index of accounts' do
    login_as (:bob)

    group1 = groups(:group1)
    team1 = teams(:team1)

    get :index, group_id: group1, team_id: team1
    assert_select '.breadcrumbs', text: 'Teams > team1 > group1'
    assert_select '.breadcrumbs a', count: 2
    assert_select '.breadcrumbs a', text: 'Teams'
    assert_select '.breadcrumbs a', text: 'team1'
    assert_select '.breadcrumbs a', text: 'group1', count: 0
  end

  test 'show breadcrump path 2 if user is on edit of accounts' do
    login_as (:bob)

    group1 = groups(:group1)
    team1 = teams(:team1)
    account1 = accounts(:account1)

    get :edit, id: account1, group_id: group1, team_id: team1
    assert_select '.breadcrumbs', text: 'Teams > team1 > group1 > account1'
    assert_select '.breadcrumbs a', count: 3
    assert_select '.breadcrumbs a', text: 'Teams'
    assert_select '.breadcrumbs a', text: 'team1'
    assert_select '.breadcrumbs a', text: 'group1'
    assert_select '.breadcrumbs a', text: 'account1', count: 0
  end

end
