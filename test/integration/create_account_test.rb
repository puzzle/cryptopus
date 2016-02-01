require 'test_helper'
class CreateAccountTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper
  test 'bob creates new account' do
    login_as('bob')

    team = teams(:team1)
    group = groups(:group1)
    accounts_path = team_group_accounts_path(team_id: team.id, group_id: group.id)

    post_via_redirect accounts_path, account: {accountname: 'e-mail', cleartext_username: 'bob@test', cleartext_password: 'alice33'}

    account = group.accounts.find_by_accountname('e-mail')
    assert account

    get team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)

    assert_select "input#cleartext_username", {value: "bob@test"}
    assert_select "input#cleartext_password", {value: "alice33"}
  end

  test 'alice reads account data' do
    login_as('alice')

    team = teams(:team1)
    group = groups(:group1)
    account = accounts(:account1)

    get team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)

    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end
end
