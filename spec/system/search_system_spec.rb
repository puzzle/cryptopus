# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'


describe 'TeamModal', type: :system, js: true do
  include SystemHelpers

  let(:bob) { users(:bob) }

  it 'finds matching accounts' do
    login_as_user(:bob)
    visit('/')

    credentials1 = encryptables(:credentials1)

    expect(find('pzsh-banner input.search')['placeholder']).to eq('Type to search in all teams...')
    find('pzsh-banner input.search').set credentials1.name

    within 'div[role="main"]' do
      expect(page).to have_text(credentials1.name)
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
      expect(page).to have_text(encryptables(:credentials1).name)
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
      expect(page).to have_text(encryptables(:credentials1).name)
      expect(page).not_to have_text(teams(:team2).name)
    end
  end

  it 'finds matching encryptable' do
    login_as_user(:bob)
    visit('/')

    private_key = decrypt_private_key(bob)
    target_folder = folders(:folder2)
    team_password = target_folder.team.decrypt_team_password(bob, private_key)
    Fabricate(:credential_all_attrs,
              folder: target_folder,
              team_password: team_password,
              name: 'Rocket Access Codes')
    Fabricate(:credential_all_attrs,
              folder: target_folder,
              team_password: team_password,
              name: 'Github Account')

    expect(find('pzsh-banner input.search')['placeholder']).to eq('Type to search in all teams...')
    find('pzsh-banner input.search').set 'Twitter'

    within 'div[role="main"]' do
      expect(page).to have_text(teams(:team2).name)
      expect(page).to have_text(folders(:folder2).name)
      expect(page).to have_text(encryptables(:credentials2).name)
      expect(page).to have_selector('.encryptable-row', count: 1)
      expect(page).not_to have_text('Rocket Access Codes')
      expect(page).not_to have_text('Github Account')
    end
  end

  it 'search starts after 2 chars' do
    login_as_user(:bob)
    visit('/')

    credentials1 = encryptables(:credentials1)

    credentials1_name_first_two_chars = credentials1.name[0...1]

    expect(find('pzsh-banner input.search')['placeholder']).to eq('Type to search in all teams...')
    find('pzsh-banner input.search').set credentials1_name_first_two_chars

    within 'div[role="main"]' do
      expect(page).to have_selector('p', text: 'Looking for a password?')
    end

    find('pzsh-banner input.search').set credentials1.name

    within 'div[role="main"]' do
      expect(page).to have_text(credentials1.name)
      expect(page).to have_text(folders(:folder1).name)
      expect(page).to have_text(teams(:team1).name)
      expect(page).not_to have_text(teams(:team2).name)
    end
  end

  it 'open credentials edit after search' do
    login_as_user(:bob)
    visit('/')

    credentials1 = encryptables(:credentials1)

    find('pzsh-banner input.search').set credentials1.name
    find(".encryptable-row-icons [src$='edit.svg']").click
    within '.modal-header' do
      expect(page).to have_text('Edit Credentials')
    end
  end

end
