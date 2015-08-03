require 'test_helper'
class CreateTeamTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
include IntegrationTest::AccountTeamSetupHelper
  test 'bob creates new normal team' do
    # Setup for test
    create_team_group_account('bob', 'password')

    login_as('bob')

    # Create account link
    team = Team.find_by_name('teamname')
    group = team.groups.find_by_name('groupname')
    account = group.accounts.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    # Bob can access team / accounts
    can_access_account(account_path, 'bob')

    # Root can access team / account
    can_access_account(account_path, 'root')

    # Admin can access team / account
    can_access_account(account_path, 'admin')

    # Destroy team
    team.destroy
  end

  test 'bob creates new noRoot team' do
    # Setup for test
    create_team_group_account_noroot('bob')
    login_as('bob')

    # Create account link
    team = Team.find_by_name('teamname')
    group = team.groups.find_by_name('groupname')
    account = group.accounts.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    # Bob can access team / accounts
    can_access_account(account_path, 'bob')

    # Root can not access team / account
    cannot_access_account(account_path, 'root')

    # Admin can access team / account
    can_access_account(account_path, 'admin')

    team.destroy
  end

  test 'bob creates private team' do
    # Setup for test
    create_team_group_account_private('bob')
    login_as('bob')

    # Create account link

    team = Team.find_by_name('teamname')
    group = team.groups.find_by_name('groupname')
    account = group.accounts.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    # Bob can not access team / accounts
    can_access_account(account_path, 'bob')

    # Root can access team / account
    can_access_account(account_path, 'root')

    # Admin can not access team / account
    cannot_access_account(account_path, 'admin')

    # Destroy team
    team.destroy
  end

  test 'bob creates private and noRoot team' do
    # Setup for test
    create_team_group_account_private_noroot('bob')
    login_as('bob')

    # Create account link
    team = Team.find_by_name('teamname')
    group = team.groups.find_by_name('groupname')
    account = group.accounts.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    # Bob can access team / accounts
    can_access_account(account_path, 'bob')

    # Root can not access team / account
    cannot_access_account(account_path, 'root')

    # Admin can not access team / account
    cannot_access_account(account_path, 'admin')

    # Destroy team
    team.destroy
  end
end
