# frozen_string_literal: true

require 'spec_helper'

describe 'Personal Team', type: :system, js: true do
  include SystemHelpers

  it 'displays personal team' do
    login_as_user(:bob)
    visit("/teams/#{users(:bob).personal_team.id}")

    personal_team_header = find('div.row.py-2.d-flex.team-card-header.rounded-top')

    expect(page).to have_selector('a.team-list-item', text: 'bob')

    within(personal_team_header) do
      # expect add folder button only
      expect(page).to have_selector('span.mx-1[role="button"]', count: 1)
    end
  end
end
