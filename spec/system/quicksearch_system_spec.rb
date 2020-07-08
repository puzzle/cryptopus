# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'QuickSearch', type: :system, js: true do
  include SystemHelpers

  before(:each) do
    login_as_user(:bob)
  end

  after(:each) do
    logout
  end

  xit 'search with not available keyword does not show any results' do
    expect(page).to have_selector('.form-group.search')

    fill_in 'q', with: 'lkj'
    expect(page).to have_no_css('li.result')
  end

  xit 'search and access account' do
    expect(page).to have_selector('.form-group.search')

    fill_in 'q', with: 'account1'
    expect(page).to have_selector('.account-entry')
    first('.account-entry').click
    expect(page).to have_content('account1')
  end

  xit 'search by get params' do
    visit('/search?q=account1')

    expect(page).to have_selector('.account-entry')
    first('.account-entry').click
    expect(page).to have_content('account1')
  end
end
