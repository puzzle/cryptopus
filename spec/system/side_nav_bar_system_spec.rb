# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe 'SideNavBar', type: :system, js: true do
  include SystemHelpers

  it 'navigate through side nav bar' do
    login_as_user(:bob)

    sidebar = page.find('div.side-nav-bar-teams-list')
    expect(sidebar).to be_present

    expect(sidebar).to have_text('team1')
    expect(sidebar).to have_text('team2')

    team1_link = find('a', text: 'team1', visible: false)
    team2_link = find('a', text: 'team2', visible: false)

    team1 = teams(:team1)
    team2 = teams(:team2)
    folder2 = folders(:folder2)

    # Click on Team and check if expands and collapses
    within(sidebar) do
      team1_collapsed_in_sidebar?
      folder2 false

      team1_link.click
      expect(uri).to eq "/teams/#{team1.id}"

      team1_expanded_in_sidebar?
      folder2 true

      # Check if Team closes up again
      team1_link.click
      team1_collapsed_in_sidebar?
      folder2 false

      # and reopen again
      team1_link.click
    end

    expect(page).to have_text(team1.name)
    expect(uri).to eq "/teams/#{team1.id}"

    within(sidebar) do
      expect(page).to have_text(team2.name)

      team2_link.click

      folder2_link = find('a', text: 'folder2', visible: false)

      folder2_link.click

      expect(uri).to eq "/teams/#{team2.id}/folders/#{folder2.id}"
    end

    logout
  end

  def folder2(shown)
    folder2_div = first('div', visible: false)
    sleep(1)
    within(folder2_div) do
      if shown
        expect(folder2_div['class']).to have_text('show')
      else
        expect(folder2_div['class']).not_to have_text('show')
      end
    end
  end

  def team1_expanded_in_sidebar?
    expect(find('a', text: 'team1', visible: false)).to have_xpath("//img[@alt='v']")
    within(all('a[role="button"]')[0]) do
      expect(find('img[alt="v"]')['src']).to include '/ember/assets/images/angle-down.svg'
    end
  end

  def team1_collapsed_in_sidebar?
    expect(find('a', text: 'team1', visible: false)).to have_xpath("//img[@alt='<']")
    within(all('a[role="button"]')[0]) do
      expect(find('img[alt="<"]')['src']).to include '/ember/assets/images/angle-left.svg'
    end
  end
end
