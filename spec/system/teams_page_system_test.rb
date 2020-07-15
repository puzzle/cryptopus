# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe 'TeamsPage', type: :system, js: true do
  include SystemHelpers

  it 'clicks through teams page' do
    login_as_user(:bob)

    account1 = accounts(:account1)

    visit('/teams')

    # Search Account
    expect(page).to have_selector('input#search')
    find('input#search', visible: false).set account1.accountname
    expect(page).to have_text(account1.accountname)

    # Look if the Nesting is expanded
    folder_expanded?
    team_expanded?

    # Click on Team in Sidebar
    team1 = teams(:team1)
    folder1 = folders(:folder1)

    within('#sidebar') do
      #Click on expand arrow in team card
      find('a', text: team1.name, visible: false).click
    end

    expect(page).to have_text(folder1.name)

    # Check if Team expands and collapses on Team name click
    all('div.col[role="button"]')[1].click
    team_collapsed?
    all('div.col[role="button"]')[1].click
    team_expanded?

    # Check if Team expanded but Folder collapsed
    team_expanded?
    folder_collapsed?

    within('#sidebar') do
      find('a', text: folder1.name, visible: false).click
    end

    expect(page).to have_selector('div.account-card')

    # Check if Folder expands and collapes on Folder name click
    all('div.col[role="button"]')[2].click
    team_collapsed?
    all('div.col[role="button"]')[2].click
    team_expanded?

    # Check if both are expanded
    team_expanded?
    folder_expanded?

    # Check if Team Edit Modal Works
    open_and_close_team_edit
    expect(page).to have_text(folder1.name)

    # Check if Team Members Modal Works
    open_and_close_team_members
    expect(page).to have_text(folder1.name)

    # Check if Team could be favourite
    click_team_favourites_button

  end

  def folder_expanded?
    within(all('div.row.border.py-2')[1]) do
      expect(find('span[role="button"]')).to have_xpath("//img[@alt='v']")
    end
  end

  def team_expanded?
    within(find('div.row.py-2.d-flex.border.rounded-top')) do
      expect(all('span[role="button"]')[3]).to have_xpath("//img[@alt='v']")
    end
  end

  def folder_collapsed?
    within(all('div.row.border.py-2')[1]) do
      expect(find('span[role="button"]')).to have_xpath("//img[@alt='<']")
    end
  end

  def team_collapsed?
    within(find('div.row.py-2.d-flex.border.rounded-top')) do
      expect(all('span[role="button"]')[3]).to have_xpath("//img[@alt='<']")
    end
  end

  def open_and_close_team_edit
    all('span[role="button"]')[0].click
    expect(page).to have_text('Edit Team')
    click_button('Close')
  end

  def open_and_close_team_members
    all('span[role="button"]')[1].click
    expect(page).to have_text('Edit Team Members and Api Users')
    click_button('Close')
  end

  def click_team_favourites_button
    all('span[role="button"]')[2].click
    within(find('div.row.py-2.d-flex.border.rounded-top')) do
      expect(find('img[alt="star"]')['src']).to include '/ember/assets/images/star.svg'
    end
    all('span[role="button"]')[2].click
    within(find('div.row.py-2.d-flex.border.rounded-top')) do
      expect(find('img[alt="star"]')['src']).to include '/ember/assets/images/star-filled.svg'
    end
  end
end
