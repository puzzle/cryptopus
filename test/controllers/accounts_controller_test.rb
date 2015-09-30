require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

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
end