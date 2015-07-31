require 'test_helper'
class CreateTeamTest < ActionDispatch::IntegrationTest

include AccountTeamSetup
  test 'bob creates new normal team' do
    #Setup for test
    create_team_group_account('bob', 'password')
    login_as('bob')

    #Create account link
    team = Team.find_by_name('teamname')
    group = Group.find_by_name('groupname')
    account = Account.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    #Bob should can access team / accounts
    can_access_account(account_path, 'bob')

    #Root shold can access team / account
    can_access_account(account_path, 'root')

    #Admin shold can access team / account
    can_access_account(account_path, 'admin')

    #Destroy team
    Team.find(team).destroy
  end

  test 'bob creates new noRoot team' do
    #Setup for test
    create_team_group_account_noroot('bob', 'password')
    login_as('bob')

    #Create account link
    team = Team.find_by_name('teamname')
    group = Group.find_by_name('groupname')
    account = Account.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    #Bob should can access team / accounts
    can_access_account(account_path, 'bob')

    #Root sholdn't can access team / account
    cannot_access_account(account_path, 'root')

    #Admin shold can access team / account
    can_access_account(account_path, 'admin')

    #Destroy team
    Team.find(team).destroy
  end

  test 'bob creates private team' do
    #Setup for test
    create_team_group_account_private('bob', 'password')
    login_as('bob')

    #Create account link
    team = Team.find_by_name('teamname')
    group = Group.find_by_name('groupname')
    account = Account.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    #Bob shouldn't can access team / accounts
    can_access_account(account_path, 'bob')

    #Root shold can access team / account
    can_access_account(account_path, 'root')

    #Admin sholdn't can access team / account
    cannot_access_account(account_path, 'admin')

    #Destroy team
    Team.find(team).destroy
  end

  test 'bob creates private and noRoot team' do
    #Setup for test
    create_team_group_account_private_noroot('bob', 'password')
    login_as('bob')

    #Create account link
    team = Team.find_by_name('teamname')
    group = Group.find_by_name('groupname')
    account = Account.find_by_accountname('accountname')
    account_path = team_group_account_path(team_id: team.id, group_id: group.id, id: account.id)
    logout

    #Bob should can access team / accounts
    can_access_account(account_path, 'bob')

    #Root sholdn't can access team / account
    cannot_access_account(account_path, 'root')

    #Admin sholdn't can access team / account
    cannot_access_account(account_path, 'admin')

    #Destroy team
    Team.find(team).destroy
  end
end
