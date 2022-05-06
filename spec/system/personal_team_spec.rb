# frozen_string_literal: true

require 'spec_helper'

describe 'Personal Team', type: :system, js: true do
  include SystemHelpers

  it 'displays personal team' do
    login_as_user(:bob)
    visit("/teams/#{users(:bob).personal_team.id}")

    expect(page).to have_selector('a.team-list-item', text: 'bob')

    # expect add folder button only
    expect(page).to have_selector('span.mx-1[role="button"]', count: 4)
  end
end
