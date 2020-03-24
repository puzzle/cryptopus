# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class LegacyRoutes::TeamsTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper

  test 'redirects to groups with without groups in url' do
    account_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}"
    login_as('bob')

    get account_url

    assert_routing "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}", controller: "groups", action: "show", team_id: "#{teams(:team1).id}", id: "#{groups(:group1).id}"
  end

  test 'redirects to teams url with groups in url' do
    redirect_url = "/teams/#{teams(:team1).id}/groups/#{groups(:group1).id}"
    account_url = "/teams/#{teams(:team1).id}/GROUPS"
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
end
