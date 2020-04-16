# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'AccountMove', type: :feature, js: true do
  include FeatureTest::FeatureHelper
  include Capybara::DSL
  Capybara.default_driver = :selenium_headless # :selenium_chrome and :selenium_chrome_headless are also registered

  it 'moves account to another team' do
    login_as_user(:bob)
    account1 = accounts(:account1)
    visit("/accounts/#{account1.id}")

    expect(page).to have_link('Move')

    click_link 'Move'

    expect(page).to have_selector('.edit_account')

    find('.move_list_team').find(:xpath, 'option[2]').select_option
    find('#movescreen_buttons').find('input').click

    expect(page).to have_content('Account was successfully moved')
  end
end
