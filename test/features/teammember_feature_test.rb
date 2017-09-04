# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'capybara'
require 'test_helper'
class TeammemberFeatureTest < Capybara::Rails::TestCase
  include FeatureTest::FeatureHelper
  include Capybara::DSL
  
  test 'lists teammembers' do
    login_as_user(:admin)
    team1 = teams(:team1)

    visit("/teams/#{team1.id}/groups")
    page.must_have_selector('.show_members')

    all('.show_members')[0].click
    
    page.must_have_content('Admin test')
    page.must_have_content('Alice test')
    page.must_have_content('Bob test')
    page.must_have_content('Root test')
  end
end
