# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'DeleteUser', type: :system, js: true do
  include SystemTest::SystemHelper

  it 'lists teams where user is last teammember' do
    login_as_user(:admin)

    visit('/admin/users')
    expect(page).to have_selector('a.delete_user_link')

    all('a.delete_user_link')[1].click

    expect(page).to have_selector('#delete_user_button')
    expect(all('#delete_user_button')[0][:disabled]).to eq('true')
    expect(page).to have_content('Before you can delete this user you have to delete ' \
                           'the following teams, because the user is the last member.')
    expect(page).to have_selector('#last_teammember_teams_table')
    expect(page).to have_content('team2')
  end

  it "can delete user if he isn't last teammember in any teams" do
    login_as_user(:admin)
    visit('/admin/users')

    all('a.delete_user_link')[0].click

    expect(page).to have_content('Are you sure you want to delete this User?')

    expect(all('#delete_user_button')[0][:disabled]).to eq('false')
    all('#delete_user_button')[0].click
    expect(page).to have_content('Deleted user alice')
  end
end
