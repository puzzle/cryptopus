# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'


describe 'FolderModal', type: :system, js: true do
  include SystemHelpers

  let(:folder_attrs) do
    { foldername: 'fld',
      description: 'desc' }
  end

  let(:updated_attrs) do
    { foldername: 'fld2',
      description: 'desc2' }
  end

  it 'creates, edits and deletes a folder' do
    login_as_user(:bob)

    # Create Folder
    expect(find('.dropdown')).to be_present
    dropdown = find('a.dropdown-toggle')
    expect(dropdown).to be_present
    dropdown.click

    find('a.dropdown-item', text: 'New Folder', visible: false).click


    expect(find('.modal-content')).to be_present
    expect(page).to have_text('New Folder')
    expect(page).to have_button('Save', visible: false)

    expect do
      fill_modal(folder_attrs)

      find('#team-power-select').find('.ember-power-select-trigger',
                                      visible: false).click # Open trigger
      find_all('ul.ember-power-select-options > li', visible: false)[0].click

      click_button('Save', visible: false)
    end.to change { Folder.count }.by(1)

    folder = Folder.find_by(name: folder_attrs[:foldername])
    team = Team.find(folder.team_id)

    visit("/teams?team_id=#{folder.team_id}&folder_id=#{folder.id}")

    expect_teams_page_with(folder_attrs, team)

    # Edit Folder
    visit("/teams?team_id=#{folder.team_id}&folder_id=#{folder.id}")
    all('img.folder-edit-icon')[0].click

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Editing Folder')
    expect(page).to have_button('Save', visible: false)

    expect_filled_fields_in_modal_with(folder_attrs)

    fill_modal(updated_attrs)
    click_button('Save', visible: false)

    expect_teams_page_with(updated_attrs, team)

    # Functionality not implemented

    # # Delete Folder
    # visit("/teams?team_id=#{folder.team_id}&folder_id=#{folder.id}")
    # expect(page).to have_text(team.name)
    #
    # expect do
    #   href = team_folder_path(team.id, folder.id)
    #   del_button = find(:xpath, "//a[@href='#{href}' and @data-method='delete']")
    #   expect(del_button).to be_present
    #
    #   accept_prompt(wait: 3) do
    #     del_button.click
    #   end
    #
    #   expect(page).to have_text("Team #{team.name}")
    # end.to change { Folder.count }.by(-1)
    #
    logout
  end

  private

  def fill_modal(folder_attrs)
    within('div.modal-content') do
      find('input[name="foldername"]').set folder_attrs[:foldername]
      find('textarea', visible: false).set folder_attrs[:description]
    end
  end

  def expect_teams_page_with(folder_attrs, team)
    expect(page).to have_text(team.name)
    expect(page).to have_text(folder_attrs[:foldername])
    expect(page).to have_text(folder_attrs[:description])
  end

  def expect_filled_fields_in_modal_with(folder_attrs)
    expect(find_field('name').value).to eq(folder_attrs[:foldername])
    expect(find('textarea', visible: false).value).to eq(folder_attrs[:description])
  end

end
