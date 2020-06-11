# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe 'TeamModal', type: :system, js: true do
  include SystemHelpers

  let(:team_attrs) do
    { name: 'niceteam',
      private: false,
      description: 'desc' }
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

    expect(page).to have_link('New team')
    click_link 'New team'

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('New team')
    expect(page).to have_button('Save')

    expect do
      fill_modal(team_attrs)
      click_button 'Save'
    end.to change { Team.count }.by(1)

    expect_team_page_with(team_attrs)

    # Edit Account
    team = Team.find_by(name: team_attrs[:name])
    visit(team_path(team.id))

    expect(page).to have_link(id: 'edit_team_button')
    click_link(id: 'edit_team_button')

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Edit team')
    expect(page).to have_button('Save')

    expect_filled_fields_in_modal_with(team_attrs)

    fill_modal(updated_attrs)
    click_button 'Save'

    expect_team_page_with(updated_attrs)

  end

  private

  def fill_modal(team_attrs)
    within('div.modal-content') do
      fill_in 'name', with: (team_attrs[:name])
      fill_in 'description', with: team_attrs[:description]
    end
  end

  def expect_team_page_with(team_attrs)
    expect(first('h1')).to have_text("Team #{team_attrs[:name]}")
    if team_attrs[:private]
      img = first('h1').first('img')
      puts img[:src]
    end
  end

  def expect_filled_fields_in_modal_with(team_attrs)
    expect(find_field('name').value).to eq(team_attrs[:name])
    expect(page).to have_field('private', disabled: true)
    expect(find_field('private', disabled: true).checked?).to be team_attrs[:private]
    expect(find('.vertical-resize').value).to eq(team_attrs[:description])
  end

end
