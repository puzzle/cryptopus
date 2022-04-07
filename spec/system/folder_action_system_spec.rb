# frozen_string_literal: true

require 'spec_helper'

describe 'FolderAction', type: :system, js: true do
  include SystemHelpers

  # Run before each testcase
  before(:each) do
    login_as_user(:admin)
    @encryptable = Encryptable.first
    @folder = Folder.find(@encryptable.folder_id)
    @team = Team.find(@folder.team_id)
  end

  # can select folder and team from side-navbar
  it 'opens folder and team in side-navbar' do

    visit('/')

    within(page.find("#side-bar-team-#{@team.id}")) do
      expect(page).to have_text(@team.name)
    end

    find("#side-bar-team-#{@team.id}").click

    expect(find('.side-nav-bar-teams-list', text: @folder.name)).to be_present
    expect(find('.team-border', text: @folder.name)).to be_present

    find('.list-folder-item', text: @folder.name).click

    expect(find('.encryptable-entry', text: @encryptable.name)).to be_present

    logout
  end

  # can select folder from team card
  it 'opens folder in team card' do

    visit("/teams/#{@team.id}")

    expect(find('.side-nav-bar-teams-list', text: @folder.name)).to be_present
    expect(find('.team-border', text: @folder.name)).to be_present

    find('.folder-card-header', text: @folder.name).click

    expect(find('.encryptable-entry', text: @encryptable.name)).to be_present

    logout
  end
end
