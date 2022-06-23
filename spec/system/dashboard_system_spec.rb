# frozen_string_literal: true

require 'spec_helper'

describe 'Dashboard', type: :system, js: true do
  include SystemHelpers

  let(:credentials) { encryptables(:credentials1) }
  let(:team) { teams(:team1) }


  it 'renders dashboard grid' do
    create_recent_credentials

    expect(page.current_path).to eq('/dashboard')
    expect(page).to have_selector('pzsh-hero', visible: true)
    expect(page).to have_selector('pzsh-banner', visible: true)
    expect(page).to have_text('Recent Credentials', count: 1)
    expect(page).to have_text('Favourites', count: 1)
    expect(page).to have_text('Teams', count: 1)

    expect(page).not_to have_selector 'div.content'

    expect(page).to have_selector('div.dashboard-grid-card', count: 4)
  end

  it 'navigates to team on team card click' do
    create_recent_credentials


    expect(page.current_path).to eq('/dashboard')

    expect(page).to have_selector('pzsh-hero', visible: true)

    first('div.dashboard-grid-card', text: team.name).click

    expect(page.current_path).to eq("/teams/#{team.id}")
    expect(page).to have_selector 'div.content'
  end

  it 'lists recently accessed encryptable' do
    create_recent_credentials

    expect(page.current_path).to eq('/dashboard')

    expect(page).to have_selector('pzsh-hero', visible: true)

    first('div.dashboard-grid-card', text: credentials.name).click

    expect(page.current_path).to eq("/encryptables/#{credentials.id}")
    expect(page).to have_selector 'div.content'
  end

  def create_recent_credentials
    login_as_user(:alice)
    visit("/encryptables/#{credentials.id}")
    visit('/dashboard')
  end
end
