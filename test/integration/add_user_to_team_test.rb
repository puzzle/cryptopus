require 'test_helper'
class AddUserToTeamTest < ActionDispatch::IntegrationTest
  test 'bob adds alice to team' do
    teammembers(:team1_alice).destroy

    login_as('bob')
    add_user_to_team_path = team_teammembers_path(teams(:team1).id)
    post add_user_to_team_path, username: 'alice', commit: 'Add'
    logout

    login_as('alice')

    get team_group_account_path(team_id: teams(:team1).id, group_id: groups(:group1).id, id: accounts(:account1).id)

    assert_select "div#hidden_username", {text: 'test'}
    assert_select "div#hidden_password", {text: 'password'}
  end
end