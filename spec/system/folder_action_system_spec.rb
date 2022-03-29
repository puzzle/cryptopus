# frozen_string_literal: true

require 'spec_helper'

describe 'FolderAction', type: :system, js: true do
  include SystemHelpers
#ist Ordner Vorhanden und auswähl bar 
  it 'shows folder' do
    login_as_user(:admin)
    visit('/')

    within(page.find('side-bar-team-34')) do
      expect(page).to have_text('Accounting 273')
    end

    logout
  end
#prüft ob Inhalt vorhanden 
  it 'shows folder content drop down' do
    login_as_user(:tux)

    within(page.find('pzsh-menu')) do
      expect(page).to have_text('Admin')
    end

    logout
    
  it 'shows folder content not dropdown' do
    login_as_user(:tux)

    end

    logout
  
  end
#
  it 'shows preselected' do
    login_as_root

    
    end

    logout
  end

  it 'sidenav click and open accouring folder' do
    login_as_user(:bob)

    end

    logout
  end
end

def folder_expanded?
    within(all('div.folder-card-header', visible: false)[0]) do
      expect(find('span[name="folder-collapse"]')).to have_xpath("//img[@alt='v']")
    end
  end

  def team_expanded?
    within(find('div.py-2.d-flex.team-card-header')) do
      expect(find('span[name="team-collapse"]')).to have_xpath("//img[@alt='v']")
    end
  end

  def folder_collapsed?
    within(all('div.folder-card-header')[1]) do
      expect(find('span[name="folder-collapse"]')).to have_xpath("//img[@alt='<']")
    end
  end

  def team_collapsed?
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
