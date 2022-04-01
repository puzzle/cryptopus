# frozen_string_literal: true

require 'spec_helper'

describe 'FolderAction', type: :system, js: true do
  include SystemHelpers
# can select folder and team from side-navbar 
  it 'opens folder and team in side-navbar' do
    login_as_user(:admin)
    visit('/')

    within(page.find('#side-bar-team-235930340')) do
      expect(page).to have_text('team1')
    end
    
    find('#side-bar-team-235930340').click
    
    within(page.first('.list-group-item.list-folder-item.bg-blue-one')) do
      expect(page).to have_text('folder1')  
    end
    
    first('.list-group-item.list-folder-item.bg-blue-one').click
    
    within(page.first('.row.d-flex.align-items-center.p-2.bg-grey-2.rounded.encryptable-entry')) do
      expect(page).to have_text('Personal Mailbox')
    end
    
    logout
    
  end

# can select folder from team card 
  it 'opens folder in team card' do
    login_as_user(:admin)
    visit('/teams/235930340')
    
    within(page.first('.pl-2.pr-2.folder-card-header')) do
      expect(page).to have_text('folder1')  
    end
    
    first('.pl-2.pr-2.folder-card-header').click
    
    within(page.first('.row.d-flex.align-items-center.p-2.bg-grey-2.rounded.encryptable-entry')) do
      expect(page).to have_text('Personal Mailbox')
    end
    
    logout
    
  end
end
