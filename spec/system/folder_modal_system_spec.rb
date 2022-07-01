# frozen_string_literal: true

require 'spec_helper'


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
      find_all('ul.ember-power-select-options > li', visible: false)[1].click

      click_button('Save', visible: false)
      expect(page).to have_selector('#nav-side-bar-container', visible: false)
    end.to change { Folder.count }.by(1)

    folder = Folder.find_by(name: folder_attrs[:foldername])
    team = Team.find(folder.team_id)

    visit("/teams?team_id=#{folder.team_id}&folder_id=#{folder.id}")

    expect_teams_page_with(folder_attrs, team)

    # Edit Folder
    visit("/teams/#{folder.team_id}/folders/#{folder.id}")
    all('img.icon-big-button[alt="edit folder"]')[0].click

    expect(find('.modal-content')).to be_present
    expect(page).to have_text('Editing Folder')
    expect(page).to have_button('Save', visible: false)

    expect_filled_fields_in_modal_with(folder_attrs)

    fill_modal(updated_attrs)
    click_button('Save', visible: false)

    expect_teams_page_with(updated_attrs, team)

    # Delete Folder
    visit("/teams?team_id=#{folder.team_id}&folder_id=#{folder.id}")
    expect(page).to have_text(team.name)

    expect do
      first('div.row.py-2.d-flex.team-card-header.rounded', visible: false).click
      del_button = all('img.icon-big-button.d-inline[alt="delete folder"]')[0]
      expect(del_button).to be_present

      del_button.click

      click_button('Delete')

      expect(page).to_not have_text folder.name
    end.to change { Folder.count }.by(-1)

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
    expect(page).to have_css('h6', visible: false, text: folder_attrs[:foldername])
    expect(page).to have_css('p', visible: false, text: folder_attrs[:description])
  end

  def expect_filled_fields_in_modal_with(folder_attrs)
    expect(find_field('name').value).to eq(folder_attrs[:foldername])
    expect(find('textarea', visible: false).value).to eq(folder_attrs[:description])
  end

end
