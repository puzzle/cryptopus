# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'capybara'
require 'test_helper'
class AjaxHookTest < Capybara::Rails::TestCase
  include FeatureTest::FeatureHelper
  include Capybara::DSL

  test 'show toggle-admin messag' do
    login_as_user('root')
    visit '/admin/users' 

    page.must_have_selector('.toggle-button')
    first('.toggle-button').click
    page.must_have_content 'admin is no more admin'
    logout
  end

  test 'show add teammember message' do
    login_as_user('bob')
    team2 = teams(:team2)
    alice = users(:alice)

    visit "/teams/#{team2.id}/groups"

    #url = "/api/teams/#{team2.id}/members"
    #page.execute_script("$.ajax({ url: #{url}, type: 'POST'})")
    logout
  end
end
