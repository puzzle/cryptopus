# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'


describe 'Create Human User', type: :system, js: true do
  include SystemHelpers

  let(:user_attrs) do
    { username: 'mmuster',
      givenname: 'Max',
      surname: 'Muster',
      password: 'password' }
  end

  it 'creates user' do
    login_as_root

    expect(page).to have_css('pzsh-menu')
    within('pzsh-menu') do
      all('pzsh-menu-dropdown').first.click
    end
    all('pzsh-menu-dropdown-item').first.click

    # Create User
    expect(page).to have_css('a.edit_button.add-user')
    find('a.edit_button.add-user').click

    expect(page).to have_text('New User')

    expect(page).to have_selector('.modal-content')
    expect(page).to have_content('Save')

    within('.modal-body') do
      expect(page).to have_selector('#password input', visible: false)
    end

    # Prove that the Passwordfield has no autocomplete
    expect(find('#password input', visible: false)['autocomplete']).to eq 'off'

    fill_modal(user_attrs)

    expect do
      click_button('Save', visible: false)
      page.driver.browser.navigate.refresh
      expect(page).to have_text(user_attrs[:username])
    end.to change { User::Human.count }.by 1

    logout
  end

  private

  def fill_modal(user_attrs)
    within('#admin-form', visible: false) do
      find('#password input', visible: false).set user_attrs[:password]
      find('#username input', visible: false).set(user_attrs[:username])
      find('#surname input', visible: false).set user_attrs[:surname]
      find('#givenname input', visible: false).set user_attrs[:givenname]
    end
  end
end
