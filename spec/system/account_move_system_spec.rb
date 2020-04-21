# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'MoveAccount', type: :system, js: true do
  include SystemTest::SystemHelper

  it 'moves account to another team' do
    login_as_user(:bob)
    account1 = accounts(:account1)
    visit("/accounts/#{account1.id}")
    expect(page).to have_link('Teams')
    expect(page).to have_link('team1')
    expect(page).to have_link('group1')
    expect(page).to have_link('Move')

    click_link 'Move'

    expect(page).to have_selector('.edit_account')

    find('.move_list_team').find(:xpath, 'option[2]').select_option
    find('#movescreen_buttons').find('input').click

    expect(page).to have_content('Account was successfully moved')
    visit("/accounts/#{account1.id}")
    expect(page).to have_link('Teams')
    expect(page).to have_link('team2')
    expect(page).to have_link('group2')
  end
end
