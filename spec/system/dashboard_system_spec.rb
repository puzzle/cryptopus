# frozen_string_literal: true

require 'spec_helper'

describe 'Dashboard', type: :system, js: true do
  include SystemHelpers

  it 'opens modal and renders content' do
    login_as_user(:alice)

    expect(page.current_path).to eq('/dashboard')

    expect(page).to have_selector('pzsh-hero', visible: true)
    expect(page).to have_selector('pzsh-banner', visible: true)
    expect(page).to have_text('Favourites', visible: true)
    expect(page).to have_text('Teams', visible: true)

    expect(page).not_to have_selector 'div.content'
  end
end
