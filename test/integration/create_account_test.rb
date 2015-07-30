require 'pry'
require 'test_helper'
class CreateAccountTest < ActionDispatch::IntegrationTest

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
end
