require 'test_helper'
class CreateAccountTest < ActionDispatch::IntegrationTest
  test 'bob adds alice to team' do
    teammembers(:team1_alice).destroy

    login_as('bob')
    add_user_to_team_link = team_teammembers_path(teams(:team1).id)
    post add_user_to_team_link, username: 'alice', commit: 'Add'
    assert Teammember.find_by_user_id(users(:alice))
    logout

    login_as('alice')

    get team_group_account_path(team_id: teams(:team1).id, group_id: groups(:group1).id, id: accounts(:account1).id)

    assert_select "div#hidden_username", {text: 'test'}
    assert_select "div#hidden_password", {text: 'password'}
  end
end