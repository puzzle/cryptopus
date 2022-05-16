# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'


describe 'TeamModal', type: :system, js: true do
  include SystemHelpers

  let(:team_attrs) do
    { name: 'bob',
      private: false,
      description: '' }
  end

  let(:updated_attrs) do
    { name: 'niceteam2',
      private: false,
      description: 'desc2' }
  end

  it 'creates, edits and deletes a team' do
    login_as_user(:bob)

    # Create Team
    expect(find('.dropdown')).to be_present
    dropdown = find('a.dropdown-toggle')
    expect(dropdown).to be_present
    dropdown.click

    find('a.dropdown-item', text: 'New Team', visible: false).click

    expect(find('.modal-content')).to be_present
    expect(page).to have_button('Save', visible: false)

    expect do
      fill_modal(team_attrs)
      click_button('Save', visible: false)
    end.to change { Team.count }.by(1)

    expect_team_page_with(team_attrs)

    # Edit Account
    team = Team.find_by(name: team_attrs[:name])
    visit("/teams?team_id=#{team.id}")

    all('img[alt="edit"]')[0].click

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit Team')
    expect(page).to have_button('Save', visible: false)

    expect_filled_fields_in_modal_with(team_attrs)

    fill_modal(updated_attrs)
    click_button('Save', visible: false)

    expect_team_page_with(updated_attrs)

  end

  private

  def fill_modal(team_attrs)
    within('div.modal-content') do
      find('input[name="teamname"]').set team_attrs[:name]
      find('textarea', visible: false).set team_attrs[:description]
    end
  end

  def expect_team_page_with(team_attrs)
    expect(page).to have_text(team_attrs[:name])
    if team_attrs[:private]
      img = first('h1').first('img')
      puts img[:src]
    end
  end

  def expect_filled_fields_in_modal_with(team_attrs)
    expect(find('input[name="teamname"]', visible: false).value).to eq(team_attrs[:name])
    expect(find('textarea', visible: false).value).to eq(team_attrs[:description])
  end

end
