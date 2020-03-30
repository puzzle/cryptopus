# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.
require 'pry'
require 'test_helper'

class LegacyRoutes::UrlTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper

  test 'redirects to groups with without groups in url' do
    account_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}"
    login_as('bob')

    get account_url

    assert_routing "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}", controller: "groups", action: "show", team_id: "#{teams(:team1).id}", id: "#{groups(:group1).id}"
  end

  test 'redirects to groups url with groups in url' do
    redirect_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/"
    account_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/accounts/"
    login_as('bob')

    get account_url

    assert_redirected_to redirect_url
  end

  test 'redirects to groups url with groups in uppercase in url' do
    redirect_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/"
    accounts_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/ACCOUNTS/"
    login_as('bob')

    get accounts_url

    assert_redirected_to redirect_url
  end

  test 'redirects to groups with groups in url' do
    team_url = "/teams/#{teams(:team1).id}/groups"
    login_as('bob')

    get team_url

    assert_routing "/teams/#{teams(:team1).id}", controller: "teams", action: "show", id: "#{teams(:team1).id}"
  end

  test 'redirects to teams url with groups in url' do
    redirect_url = "/teams/#{teams(:team1).id}/"
    team_url = "/teams/#{teams(:team1).id}/GROUPS"
    login_as('bob')

    get team_url

    assert_redirected_to redirect_url
  end

  test 'redirects to teams url with groups in uppercase in url' do
    redirect_url = "/teams/#{teams(:team1).id}/"
    team_url = team_groups_path(teams(:team1).id)
    login_as('bob')

    get team_url

    assert_redirected_to redirect_url
  end

  test 'redirects to team1 url without locale' do
    team_url = "/teams/#{teams(:team1).id}/"
    login_as('bob')

    get "/de/teams/#{teams(:team1).id}/groups"

    assert_redirected_to team_url
  end

  test 'redirects to teams url without locale' do
    login_as('bob')

    get '/de/teams'

    assert_redirected_to teams_path
  end

  test 'redirects to login url without locale' do
    get '/de/login/login'

    assert_redirected_to login_login_path
  end

  test 'redirects to account url without locale' do
    accounts_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/"
    login_as('bob')
    
    get "/de/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}/accounts"

    assert_redirected_to accounts_url
  end

  test 'redirects to profile url without locale' do
    login_as('bob')
    get '/de/profile'

    assert_redirected_to profile_path
  end

  test 'redirects to search url without locale' do
    login_as('bob')
    get '/de/search?q='

    assert_redirected_to search_path
  end

  test 'redirects to admin settings url without locale' do
    login_as('bob')
    get '/de/admin/settings/index'

    assert_redirected_to admin_settings_path
  end

  test 'redirects to profile url without locale in uppercase' do
    login_as('bob')
    get '/DE/admin/settings/index'

    assert_redirected_to admin_settings_path
  end
end
