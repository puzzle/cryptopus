# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'
describe 'QuickSearchFeature', type: :feature, js: true do
  include FeatureTest::FeatureHelper
  include Capybara::DSL

  before(:each) do
    login_as_user(:bob)
    visit '/search'
  end

  after(:each) do
    logout
  end

  it 'search with not available keyword does not show any results' do
    expect(page).to have_selector('.form-group.search')

    fill_in 'q', with: 'lkj'
    expect(page).to have_no_css('li.result')
  end

  it 'search and access account' do
    expect(page).to have_selector('.form-group.search')

    fill_in 'q', with: 'account1'
    expect(page).to have_selector('.account-entry')
    all('.account-entry')[0].click
    expect(page).to have_content('account1')
  end

  it 'search by get params' do
    visit('/search?q=account1')

    expect(page).to have_selector('.account-entry')
    all('.account-entry')[0].click
    expect(page).to have_content('account1')
  end
end
