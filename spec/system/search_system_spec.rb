# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'


describe 'TeamModal', type: :system, js: true do
  include SystemHelpers

  it 'finds matching accounts' do
    login_as_user(:bob)
    visit('/')

    account1 = encryptables(:credential1)

    expect(find('pzsh-banner input.search')['placeholder']).to eq('Type to search in all teams...')
    find('pzsh-banner input.search').set account1.name

    within 'div[role="main"]' do
      expect(page).to have_text(account1.name)
      expect(page).to have_text(folders(:folder1).name)
      expect(page).to have_text(teams(:team1).name)
      expect(page).not_to have_text(teams(:team2).name)
    end
  end

  it 'finds matching folders' do
    login_as_user(:bob)
    folder1 = folders(:folder1)

    expect(find('pzsh-banner input.search')['placeholder']).to eq('Type to search in all teams...')
    find('pzsh-banner input.search').set folder1.name

    within 'div[role="main"]' do
      expect(page).to have_text(folder1.name)
      expect(page).to have_text(teams(:team1).name)
      expect(page).to have_text(encryptables(:credential1).name)
      expect(page).not_to have_text(folders(:folder2).name)
      expect(page).not_to have_text(teams(:team2).name)
    end
  end

  it 'finds matching teams' do
    login_as_user(:bob)
    visit('/')

    team1 = teams(:team1)

    expect(find('pzsh-banner input.search')['placeholder']).to eq('Type to search in all teams...')
    find('pzsh-banner input.search').set team1.name

    within 'div[role="main"]' do
      expect(page).to have_text(team1.name)
      expect(page).to have_text(folders(:folder1).name)
      expect(page).to have_text(encryptables(:credential1).name)
      expect(page).not_to have_text(teams(:team2).name)
    end
  end

  it 'search starts after 2 chars' do
    login_as_user(:bob)
    visit('/')

    account1 = encryptables(:credential1)

    account1_name_first_two_chars = account1.name[0...1]

    expect(find('pzsh-banner input.search')['placeholder']).to eq('Type to search in all teams...')
    find('pzsh-banner input.search').set account1_name_first_two_chars

    within 'div[role="main"]' do
      expect(page).to have_selector('p', text: 'Looking for a password?')
    end

    find('pzsh-banner input.search').set account1.name

    within 'div[role="main"]' do
      expect(page).to have_text(account1.name)
      expect(page).to have_text(folders(:folder1).name)
      expect(page).to have_text(teams(:team1).name)
      expect(page).not_to have_text(teams(:team2).name)
    end
  end

end
