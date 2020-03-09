# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class LegacyRoutes::LocaleTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper

  test 'redirects to team1 url without locale' do
    team_url = team_groups_path(teams(:team1).id)
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
    login_as('bob')
    accounts_url = team_group_accounts_path(teams(:team1).id, groups(:group1).id)
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
