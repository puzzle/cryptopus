require 'test_helper'
class CreateAccountTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper
  test 'bob creates new account' do
    login_as('bob')

    team = teams(:team1)
    group = groups(:group1)
    accounts_path = team_group_accounts_path(team_id: team.id, group_id: group.id)

    post_via_redirect accounts_path, account: {accountname: 'e-mail', username: 'bob@test', password: 'alice33'}

    account = group.accounts.find_by_accountname('e-mail')
    assert account

    get team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)

    assert_select "div#hidden_username", {text: 'bob@test'}
    assert_select "div#hidden_password", {text: 'alice33'}
  end

  test 'alice reads account data' do
    login_as('alice')

    team = teams(:team1)
    group = groups(:group1)
    account = accounts(:account1)

    get team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)

    assert_select "div#hidden_username", {text: 'test'}
    assert_select "div#hidden_password", {text: 'password'}
  end

  test 'move account from one group to another' do
    login_as ('bob')

    account1 = accounts(:account1)
    group_path = team_groups_path(teams(:team1))
    post_via_redirect group_path, group: {name: 'Test', description: 'group_description'}

    group2_id = Group.find_by_name('Test').id
    account_path = team_group_account_path(account1.group.team,
                                                account1.group,
                                                account1)
    patch account_path, account: {group_id: group2_id}
    account1.reload
    assert_equal account1.group_id, group2_id
  end
end
