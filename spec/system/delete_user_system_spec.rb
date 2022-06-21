# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe 'DeleteUser', type: :system, js: true do
  include SystemHelpers

  it 'lists teams where user is last teammember' do
    login_as_user(:admin)

    visit('/admin/users')

    expect(page).to have_selector('span img.icon-button[alt="delete"]')

    all('span img.icon-button[alt="delete"]')[1].click

    expect(page).to have_selector('span img.icon-button')
    expect(find('button.btn-danger', exact_text: 'Delete')[:disabled]).to eq('true')
    expect(page).to have_content('Before you can delete this user you have to delete ' \
                           'the following teams, because the user is the last member.')
    expect(page).to have_selector('div.modal table')
    expect(page).to have_content('team2')
  end

  it "can't delete user if he is last teammember in any teams" do
    login_as_user(:admin)
    visit('/admin/users')

    all('span img.icon-button[alt="delete"]')[0].click

    expect(find('button.btn-danger', exact_text: 'Delete')[:disabled]).to eq('true')

    expect(page).to have_selector('div.modal table')
  end
end
