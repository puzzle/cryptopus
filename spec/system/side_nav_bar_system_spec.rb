# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'


describe 'SideNavBar', type: :system, js: true do
  include SystemHelpers

  it 'navigate through side nav bar' do
    login_as_user(:bob)
    visit('/')

    sidebar = page.find('div.side-nav-bar-teams-list')
    expect(sidebar).to be_present

    expect(sidebar).to have_text('team1')
    expect(sidebar).to have_text('team2')

    team1_link = all('a.list-group-item')[1]
    team2_link = all('a.list-group-item').last

    team1 = teams(:team1)
    team2 = teams(:team2)
    folder2 = folders(:folder2)

    # Click on Team and check if expands and collapses
    within(sidebar) do
      team1_collapsed_in_sidebar?
      assert_folder2(shown: false)

      team1_link.click
      page.has_css?('div.folder-show-header')
      expect(uri).to eq "/teams/#{team1.id}"

      team1_expanded_in_sidebar?
      assert_folder2(shown: true)

      # Check if Team closes up again
      team1_link.click
      team1_collapsed_in_sidebar?
      assert_folder2(shown: false)

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

  private

  def assert_folder2(shown:)
    folder2_div = first('div', visible: false)
    if shown
      folder2_div.has_css?('collapsing')
      folder2_div.has_css?('show')
    else
      folder2_div.has_no_css?('show')
    end
  end

  def team1_expanded_in_sidebar?
    expect(find('a', text: 'team1', visible: false)).to have_xpath("//img[@alt='v']")
    within(all('a[role="button"]')[1]) do
      expect(find('img[alt="v"]')['src']).to include '/assets/images/angle-down.svg'
    end
  end

  def team1_collapsed_in_sidebar?
    expect(find('a', text: 'team1', visible: false)).to have_xpath("//img[@alt='<']")
    within(all('a[role="button"]')[1]) do
      expect(find('img[alt="<"]')['src']).to include '/assets/images/angle-left.svg'
    end
  end
end
