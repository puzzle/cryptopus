require 'pry'
require 'test_helper'
class CreateAccountTest < ActionDispatch::IntegrationTest
  test 'bob creates new account' do
    binding.pry
    team = Team.find_by_name('team1')
    group = Group.find_by_name('group1')
    account_link = team_group_accounts_path(team: team, group: group)
    post account_link, account: {accountname: 'test', username: 'test', password: 'password'}
    account = Account.find_by_accountname('test')
    get team_group_account_path(team, group, account)
    assert_select "div#hidden_username", {text: "account_username"}
    assert_select "div#hidden_password", {text: "account_password"}
  end
end