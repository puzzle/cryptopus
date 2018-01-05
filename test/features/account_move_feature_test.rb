# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountMoveTest < Capybara::Rails::TestCase
  include FeatureTest::FeatureHelper
  include Capybara::DSL

  test 'moves account to another team' do
    login_as_user(:bob)
    team1 = teams(:team1)
    group1 = groups(:group1)
    account1 = accounts(:account1)
    team2 = teams(:team2)
    group2 = groups(:group2)

    visit("/teams/#{team1.id}/groups/#{group1.id}/accounts/#{account1.id}")
    page.must_have_selector('#move_account_button')
    all('#move_account_button')[0].click
    page.must_have_selector('.edit_account')
    find('.move_list_team').find(:xpath, 'option[2]').select_option
    find("#movescreen_buttons").find("input").click
    using_wait_time 10 do
      visit("/teams/#{team2.id}/groups/#{group2.id}/accounts/#{account1.id}")
    end

  end
end
