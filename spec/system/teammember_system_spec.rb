# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'capybara'
require 'rails_helper'

describe 'Teammember', type: :system do
  include SystemHelpers

  it 'lists teammembers' do
    login_as_user(:admin)
    team1 = teams(:team1)

    visit("/teams/#{team1.id}")

    edit_button = page.find_link(id: 'edit_account_button')
    expect(edit_button).to be_present
    edit_button.click


    # expect(page).to have_content('Admin test')
    # expect(page).to have_content('Alice test')
    # expect(page).to have_content('Bob test')
    # expect(page).to have_content('Root test')


  end
end
