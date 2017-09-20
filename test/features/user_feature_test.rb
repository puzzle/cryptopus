# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
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
    page.must_have_selector('a.delete_user_link')

    all('a.delete_user_link')[1].click

    page.must_have_selector('#delete_user_button')
    assert_equal all('#delete_user_button')[0][:disabled], 'true'

    page.must_have_content('Before you can delete this user you have to delete the following teams, because the user is the last member.')
    page.must_have_selector('#last_teammember_teams_table')
    page.must_have_content('team2')
  end

  test "can delete user if he hasn't ast teammember teams" do
    login_as_user(:admin)
    visit('/admin/users')

    all('a.delete_user_link')[0].click

    page.must_have_content('Are you sure you want to delete this User?')

    assert_nil all('#delete_user_button')[0][:disabled]

    all('#delete_user_button')[0].click
    assert_not page.has_content?('alice')
  end
end
