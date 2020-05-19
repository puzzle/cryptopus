# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

# Rspec does load somewhat differently, to avoid a autoload error, those are included like that.
require_relative '../../app/controllers/api/teams/api_users_controller'
require_relative '../../app/controllers/api/teams/members_controller'


describe 'Teammember', type: :system, js: true do
  include SystemHelpers

  it 'lists teammembers' do

    login_as_user(:admin)
    team1 = teams(:team1)

    # Make Api-User, as modal doesn't work yet without.
    visit '/profile'
    click_link 'Api Users'
    click_button 'New'

    visit("/teams/#{team1.id}")

    edit_button = page.find_link(id: 'edit_account_button')
    expect(edit_button).to be_present
    edit_button.click

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit Team Members and Api Users')
    expect(page).to have_button('Close')


    within('#members') do
      expect(page).to have_content('Admin test')
      expect(page).to have_content('Alice test')
      expect(page).to have_content('Bob test')
      expect(page).to have_content('Root test')

      within(page.find('li', text: 'Admin test')) do
        expect(find('img')['src']).to have_content 'penguin'
      end

      # Delete Alice
      within(page.find('li', text: 'Alice test')) do

        expect(find('img')['src']).to have_content 'remove'

        expect do
          find('img').click
        end.to change { Teammember.count }.by(-1)
      end

      # Add Alice
      expect do
        fill_in class: 'ember-power-select-typeahead-input', with: 'A'
        within('.ember-power-select-options') do
          find('li', match: :first).click
        end
      end.to change { Teammember.count }.by(1)

    end

    # Enable an Api-User
    click_link 'Api Users'

    within('#api-users') do

      expect('.tab-pane #api-users').to be_present

      api_user = users(:admin).api_users.first
      expect(page).to have_content(api_user.username)

      expect do
        find('.x-toggle-btn').click
      end.to change { Teammember.count }.by(1)

    end

  end
end
