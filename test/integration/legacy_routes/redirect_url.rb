# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class LegacyRoutesRedirectTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper

  #/de/teams/1/groups/1 -> /teams/1/groups/1/
  test 'redirects to groups with without groups in url' do
    legacy_account_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to team_group_path(teams(:team1).id, groups(:group1).id)
  end

  #/de/teams/1/groups/1/accounts -> /teams/1/groups/1/
  test 'redirects to groups url with groups in url' do
    legacy_account_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to accounts_path(teams(:team1).id, groups(:group1).id)
  end

  #/de/teams/1/groups -> /teams/1/
  test 'redirects to groups with groups in url' do
    legacy_team_url = "/de/teams/#{teams(:team1).id}/groups"
    login_as('bob')

    get legacy_team_url

    assert_redirected_to teams_path(teams(:team1).id)
  end

  #/de/teams/1/groups/1/ -> /teams/1/groups/1/
  test 'redirects to teams url with locale in url' do
    legacy_team_url = "/de/teams/#{teams(:team1).id}/"
    redirect_url = team_groups_path(teams(:team1).id)
    login_as('bob')

    get legacy_team_url

    assert_redirected_to redirect_url
  end

  #/de/teams/1/groups/1/accounts/1/ -> /accounts/1/
  test 'redirects to team1 url without locale' do
    legacy_account_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/accounts/#{accounts(:account1).id}/"
    login_as('bob')

    get legacy_account_url

    assert_redirected_to account_path(teams(:team1).id, groups(:group1).id, accounts(:account1).id)
  end

  #/de/teams' -> /teams
  test 'redirects to teams url without locale' do
    login_as('bob')

    get '/de/teams'

    assert_redirected_to teams_path
  end

  #/de/login/login -> /login/login
  test 'redirects to login url without locale' do
    get '/de/login/login'

    assert_redirected_to login_login_path
  end

  #/de/teams/1/groups/1/accounts -> /accounts
  test 'redirects to account url without locale' do
    accounts_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/"
    legacy_accounts_url = "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/accounts"
    login_as('bob')

    get legacy_accounts_url

    assert_redirected_to accounts_url
  end

  #/de/profile -> /profile
  test 'redirects to profile url without locale' do
    login_as('bob')
    get '/de/profile'

    assert_redirected_to profile_path
  end

  #/de/search?q= -> /search?q=
  test 'redirects to search url without locale' do
    login_as('bob')
    get '/de/search?q='

    assert_redirected_to search_path
  end

  #/de/admin/settings/index -> /admin/settings/index
  test 'redirects to admin settings url without locale' do
    login_as('bob')
    get '/de/admin/settings/index'

    assert_redirected_to admin_settings_path
  end
end
