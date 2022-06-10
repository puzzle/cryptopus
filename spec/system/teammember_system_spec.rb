# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

# Rspec does load somewhat differently, to avoid a autoload error, those are included like that.
require_relative '../../app/controllers/api/teams/api_users_controller'
require_relative '../../app/controllers/api/teams/members_controller'


describe 'Teammember', type: :system, js: true do
  include SystemHelpers

  it 'lists teammembers' do
    login_as_user(:admin)
    visit('/')

    expect(page).to have_css('p', visible: false, text: 'Looking for a password?')
    team1_link = find('a.team-list-item', text: 'team1')
    team1_link.click

    find('img[alt="configure"]').click

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit Team Members and Api Users')

    within('#members') do
      expect(page).to have_content('Admin test')
      expect(page).to have_content('Alice test')
      expect(page).to have_content('Bob test')
      expect(page).to have_content('Root test')

      # Delete Alice
      within(page.find('div.col')) do
        expect do
          all('a[role="button"]')[0].click
          expect(all('a[role="button"]').count).to eq 1
        end.to change { Teammember.count }.by(-1)
      end

      # Add Alice
      expect do
        fill_in class: 'ember-power-select-typeahead-input', visible: false, with: 'A'
        find('.ember-power-select-typeahead-input', visible: false).click

        within('.ember-power-select-options', visible: false) do
          find('li', match: :first).click
        end
      end.to change { Teammember.count }.by(1)
    end
  end
end
