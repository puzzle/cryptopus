# frozen_string_literal: true

require 'spec_helper'

describe 'Dashboard', type: :system, js: true do
  include SystemHelpers

  it 'renders dashboard grid' do
    login_as_user(:alice)

    expect(page.current_path).to eq('/dashboard')

    expect(page).to have_selector('pzsh-hero', visible: true)
    expect(page).to have_selector('pzsh-banner', visible: true)
    expect(page).to have_text('Recent Credentials', count: 1)
    expect(page).to have_text('Favourites', count: 1)
    expect(page).to have_text('Teams', count: 1)

    expect(page).not_to have_selector 'div.content'

    expect(page).to have_selector('div.dashboard-grid-card', count: 3)
  end

  it 'navigates to team on team card click' do
    login_as_user(:alice)

    expect(page.current_path).to eq('/dashboard')

    expect(page).to have_selector('pzsh-hero', visible: true)

    team = Team.first

    first('div.dashboard-grid-card', text: team.name).click

    expect(page.current_path).to eq("/teams/#{team.id}")
    expect(page).to have_selector 'div.content'
  end
  
  it 'navigates to encryptable on encryptable card click' do
    login_as_user(:alice)

    expect(page.current_path).to eq('/dashboard')

    expect(page).to have_selector('pzsh-hero', visible: true)

    encryptable = Encryptable.first

    first('div.dashboard-grid-card', text: encryptable.name).click

    expect(page.current_path).to eq("/encryptables/#{encryptable.id}")
    expect(page).to have_selector 'div.content'
  end
end
