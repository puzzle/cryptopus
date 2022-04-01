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
    
    expect_team_expanded
    
    within(page.first('.list-group-item.list-folder-item.bg-blue-one')) do
      expect(page).to have_text('folder1')  
    end
    
    first('.list-group-item.list-folder-item.bg-blue-one').click
    
    expect_folder_expanded
    
    
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
#
  it 'shows preselected' do
    login_as_root

    logout
  end


def expect_folder_expanded
    within(all('div.folder-card-header', visible: false)[0]) do
      expect(find('span[name="folder-collapse"]')).to have_xpath("//img[@alt='v']")
    end
  end

  def expect_team_expanded
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('span[name="team-collapse"]')).to have_xpath("//img[@alt='v']")
    end
  end

  def expect_folder_collapsed
    within(all('div.folder-card-header')[1]) do
      expect(find('span[name="folder-collapse"]')).to have_xpath("//img[@alt='<']")
    end
  end

  def expect_team_collapsed
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('span[name="team-collapse"]')).to have_xpath("//img[@alt='<']")
    end
  end

  def open_and_close_team_edit
    all('span[role="button"]')[1].click
    expect(page).to have_text('Edit Team')
    find('button.btn.btn-secondary.ember-view', text: 'Close', visible: false).click
  end

  def open_and_close_team_members
    all('span[role="button"]')[2].click
    expect(page).to have_text('Edit Team Members and Api Users')
    find('button.btn.btn-secondary.ember-view', text: 'Close', visible: false).click
  end

  def click_team_favourites_button
    all('span[role="button"]')[3].click
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('img[alt="star"]')['src']).to include '/assets/images/star-white-filled.svg'
    end
    all('span[role="button"]')[3].click
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('img[alt="star"]')['src']).to include '/assets/images/star-white.svg'
    end
  end
end
