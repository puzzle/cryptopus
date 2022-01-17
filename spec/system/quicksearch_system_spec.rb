# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe 'QuickSearch', type: :system, js: true do
  include SystemHelpers

  before(:each) do
    login_as_user(:bob)
  end

  after(:each) do
    logout
  end

  let(:encryptable_credential1) { encryptables(:credential1) }

  it 'search with not available keyword does not show any results' do
    expect(find('input.search')['placeholder']).to eq('Type to search in all teams...')
    expect(page).to have_selector('input.search')

    find('input.search').set 'lkj'
    expect(page).to have_no_css('li.result')
  end

  it 'search and access account' do
    expect(find('input.search')['placeholder']).to eq('Type to search in all teams...')
    expect(page).to have_selector('input.search')

    find('input.search').set account1.name
    expect(page).to have_selector('.account-entry')
    within('div.account-entry') do
      expect(page).to have_content(account1.name)
    end
  end

  it 'search by get params' do
    find('input.search').set 'account1'

    expect(page).to have_selector('.account-entry')
    within('div.account-entry') do
      expect(page).to have_content(account1.name)
    end
  end
end
