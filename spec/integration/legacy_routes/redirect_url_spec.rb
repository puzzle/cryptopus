# frozen_string_literal: true

require 'rails_helper'

describe LegacyRoutes::RedirectUrl do
  include IntegrationHelpers::DefaultHelper

  # /de/teams/1/groups/1 -> /teams/1/groups/1/
  it 'redirects to groups without groups in url' do
    team1 = teams(:team1)
    group1 = groups(:group1)

    legacy_account_url = "/de/teams/#{team1.id}/groups/#{group1.id}"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to team_group_path(team1.id, group1.id)
  end

  # /de/teams/1/groups/1/accounts -> /teams/1/groups/1/
  it 'redirects to accounts url with accounts in legacy url' do
    team1 = teams(:team1)
    group1 = groups(:group1)

    legacy_account_url = "/de/teams/#{team1.id}/groups/#{group1.id}/accounts"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to team_group_path(teams(:team1).id, groups(:group1).id)
  end

  # /de/teams/1/groups -> /teams/1/
  it 'redirects to groups with groups in url' do
    team1 = teams(:team1)

    legacy_team_url = "/de/teams/#{team1.id}/groups"
    login_as('bob')

    get legacy_team_url

    assert_redirected_to team_path(teams(:team1).id)
  end

  # /de/teams/1/groups/1/ -> /teams/1/groups/1/
  it 'redirects to teams url with locale in url' do
    team1 = teams(:team1)

    legacy_team_url = "/de/teams/#{team1.id}/"
    redirect_url = team_path(team1.id)
    login_as('bob')

    get legacy_team_url

    assert_redirected_to redirect_url
  end

  # /de/teams/1/groups/1/accounts/1/ -> /accounts/1/
  it 'redirects to team1 url without locale' do
    team1 = teams(:team1)
    group1 = groups(:group1)
    account1 = accounts(:account1)

    legacy_account_url = "/de/teams/#{team1.id}/groups/" \
    "#{group1.id}/accounts/#{account1.id}/"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to account_path(account1)
  end

  # /de/teams -> /teams
  it 'redirects to teams url with german locale' do
    login_as('bob')

    get '/de/teams'

    assert_redirected_to teams_path
  end

  # /en/teams -> /teams
  it 'redirects to teams url with english locale' do
    login_as('bob')

    get '/en/teams'

    assert_redirected_to teams_path
  end

  # /fr/teams -> /teams
  it 'redirects to teams url with french locale' do
    login_as('bob')

    get '/fr/teams'

    assert_redirected_to teams_path
  end

  # /de/login/login -> /login/login
  it 'redirects to login url without locale' do
    get '/de/login/login'

    assert_redirected_to session_new_path
  end

  # /de/teams/1/groups/1/accounts -> /accounts
  it 'redirects to account url without locale' do
    team1 = teams(:team1)
    group1 = groups(:group1)

    legacy_accounts_url = "/de/teams/#{team1.id}/groups/#{group1.id}/accounts"
    login_as('bob')

    get legacy_accounts_url

    assert_redirected_to team_group_path(team1, group1)
  end

  # /de/profile -> /profile
  it 'redirects to profile url without locale' do
    login_as('bob')
    get '/de/profile'

    assert_redirected_to profile_path
  end

  # /de/search?q= -> /search?q=
  it 'redirects to search url without locale' do
    login_as('bob')
    get '/de/search?q='

    assert_redirected_to search_path
  end

  # /de/admin/settings/index -> /admin/settings/index
  it 'redirects to admin settings url without locale' do
    login_as('bob')
    get '/de/admin/settings/index'

    assert_redirected_to admin_settings_path
  end

  # /de/teams/1/groups/1/accountes -> RoutingError
  it 'raises RoutingError when user accesses non valid route' do
    team1 = teams(:team1)
    group1 = groups(:group1)

    invalid_account_url = "/teams/#{team1.id}/groups/#{group1.id}/accountes"
    login_as('bob')

    expect { get invalid_account_url }.to raise_error(ActionController::RoutingError)
  end

  # /ch_vs/teams/1/groups/1/accounts -> RoutingError
  it 'raises RoutingError when user accesses non valid route with unknown locale' do

    invalid_teams_url = '/ch_vs/teams'
    login_as('bob')

    expect { get invalid_teams_url }.to raise_error(ActionController::RoutingError)
  end

  # /en/login/login -> /
  it 'redirects to to root path for old login path' do
    get '/en/login/login'

    assert_redirected_to session_new_path

    login_as('bob')

    assert_redirected_to root_path
  end
end
