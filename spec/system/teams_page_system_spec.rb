# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

# Rspec does load somewhat differently, to avoid a autoload error, those are included like that.
require_relative '../../app/controllers/api/teams/members_controller'

describe 'TeamsPage', type: :system, js: true do
  include SystemHelpers

  it 'clicks through teams page' do
    login_as_user(:bob)
    visit('/')

    account1 = accounts(:account1)

    expect(page).to have_selector('input.search')
    find('input.search', visible: false).set account1.name
    expect(page).to have_text(account1.name)

    # Look if the Nesting is expanded
    folder_expanded?
    team_expanded?

    # Click on Team in Sidebar
    team1 = teams(:team1)
    folder1 = folders(:folder1)

    within('#sidebar') do
      # Click on expand arrow in team card
      find('a', text: team1.name, visible: false).click
    end

    # Check if visible in teams page
    within(find('div.col.px-4.list-folder-header')) do
      expect(page).to have_text(folder1.name)
    end

    # Check if Team expands and collapses on Team name click
    all('div.col[role="button"]')[1].click
    team_collapsed?
    all('div.col[role="button"]')[1].click
    team_expanded?

    # Check if Team expanded but Folder collapsed
    folder_collapsed?

    within('#sidebar') do
      find('a', text: folder1.name, visible: false).click
    end

    expect(page).to have_selector('div.account-entry')

    # Check if Folder expands and collapes on Folder name click
    all('div.col[role="button"]')[1].click
    folder_collapsed?
    all('div.col[role="button"]')[2].click
    folder_expanded?

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
    within(all('div.folder-card-header', visible: false)[0]) do
      expect(find('span[name="folder-collapse"]')).to have_xpath("//img[@alt='v']")
    end
  end

  def team_expanded?
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('span[name="team-collapse"]')).to have_xpath("//img[@alt='v']")
    end
  end

  def folder_collapsed?
    within(all('div.folder-card-header')[1]) do
      expect(find('span[name="folder-collapse"]')).to have_xpath("//img[@alt='<']")
    end
  end

  def team_collapsed?
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('span[name="team-collapse"]')).to have_xpath("//img[@alt='<']")
    end
  end

  def open_and_close_team_edit
    all('span[role="button"]')[1].click
    expect(page).to have_text('Edit Team')
    find('button.btn.btn-secondary.ember-view', text: 'Close', visible: false).click
  end

  def open_and_close_team_members
    all('span[role="button"]')[2].click
    expect(page).to have_text('Edit Team Members and Api Users')
    find('button.btn.btn-secondary.ember-view', text: 'Close', visible: false).click
  end

  def click_team_favourites_button
    all('span[role="button"]')[3].click
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('img[alt="star"]')['src']).to include '/assets/images/star-white-filled.svg'
    end
    all('span[role="button"]')[3].click
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('img[alt="star"]')['src']).to include '/assets/images/star-white.svg'
    end
  end
end
