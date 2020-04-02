# frozen_string_literal: true

require 'rails_helper'

describe LegacyRoutes::RedirectUrl do
  include IntegrationTest::DefaultHelper

  #/de/teams/1/groups/1 -> /teams/1/groups/1/
  it 'redirects to groups without groups in url' do
    legacy_account_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to team_group_path(teams(:team1).id, groups(:group1).id)
  end

  #/de/teams/1/groups/1/accounts -> /teams/1/groups/1/
  it 'redirects to accounts url with accounts in legacy url' do
    legacy_account_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/accounts"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to team_group_path(teams(:team1).id, groups(:group1).id)
  end

  #/de/teams/1/groups -> /teams/1/
  it 'redirects to groups with groups in url' do
    legacy_team_url = "/de/teams/#{teams(:team1).id}/groups"
    login_as('bob')

    get legacy_team_url

    assert_redirected_to team_path(teams(:team1).id)
  end

  #/de/teams/1/groups/1/ -> /teams/1/groups/1/
  it 'redirects to teams url with locale in url' do
    legacy_team_url = "/de/teams/#{teams(:team1).id}/"
    redirect_url = team_path(teams(:team1).id)
    login_as('bob')

    get legacy_team_url

    assert_redirected_to redirect_url
  end

  #/de/teams/1/groups/1/accounts/1/ -> /accounts/1/
  it 'redirects to team1 url without locale' do
    legacy_account_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/accounts/#{accounts(:account1).id}/"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to account_path(accounts(:account1))
  end

  #/de/teams' -> /teams
  it 'redirects to teams url without locale' do
    login_as('bob')

    get '/de/teams'

    assert_redirected_to teams_path
  end

  #/de/login/login -> /login/login
  it 'redirects to login url without locale' do
    get '/de/login/login'

    assert_redirected_to login_login_path
  end

  #/de/teams/1/groups/1/accounts -> /accounts
  it 'redirects to account url without locale' do
    legacy_accounts_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/accounts"
    login_as('bob')

    get legacy_accounts_url

    assert_redirected_to team_group_path(teams(:team1), groups(:group1))
  end

  #/de/profile -> /profile
  it 'redirects to profile url without locale' do
    login_as('bob')
    get '/de/profile'

    assert_redirected_to profile_path
  end

  #/de/search?q= -> /search?q=
  it 'redirects to search url without locale' do
    login_as('bob')
    get '/de/search?q='

    assert_redirected_to search_path
  end

  #/de/admin/settings/index -> /admin/settings/index
  it 'redirects to admin settings url without locale' do
    login_as('bob')
    get '/de/admin/settings/index'

    assert_redirected_to admin_settings_path
  end
end
