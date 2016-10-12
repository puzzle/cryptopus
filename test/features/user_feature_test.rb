# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class UserFeatureTest < Capybara::Rails::TestCase
  include FeatureTest::FeatureHelper
  include Capybara::DSL

  test 'lists teams where user is last teammember' do
    login_as_user(:admin)
    visit('/admin/users')

    find(:xpath, './/a[@data-user-id="902541635"]').click

    page.must_have_content('Before you can delete this user you have to delete the following teams, because the user is the last member.') 
    page.must_have_selector('#last_teammember_teams_table')
    page.must_have_content('team2')
  end
end
