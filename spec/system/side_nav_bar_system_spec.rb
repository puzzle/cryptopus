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

    sidebar = page.find('#sidebar')
    expect(sidebar).to be_present

    expect(sidebar).to have_text('team1')
    expect(sidebar).to have_text('team2')

    within(sidebar) do
      team1_link = find('a', text: 'team1', visible: false)
      team2_link = find('a', text: 'team2', visible: false)

      team1 = teams(:team1)
      team2 = teams(:team2)
      folder2 = folders(:folder2)

      expect(team1_link).to have_xpath("//img[@alt='<']")
      team1_link.click
      expect(team1_link).to have_xpath("//img[@alt='v']")

      expect(uri).to eq "/teams/#{team1.id}"
      # TODO: check if page shows this team

      expect(page).to have_text(team2.name)

      team2_link.click

      folder2_link = find('a', text: 'folder2', visible: false)

      folder2_link.click


      expect(uri).to eq "/teams/#{team2.id}/folders/#{folder2.id}"
      # TODO: check if page expanded correct folder

    end

    logout
  end

end
