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
    login_as_user(:admin)

    visit('/admin/users')

    # Create User
    expect(page).to have_css('button.btn.btn-primary', exact_text: 'New')
    find('button.btn.btn-primary', exact_text: 'New').click

    expect(page).to have_text('New User')

    expect(page).to have_selector('.modal-content')
    expect(page).to have_content('Save')

    within('.modal-body.ember-view') do
      expect(page).to have_selector("input[name='password']", visible: false)
    end

    # Prove that the Passwordfield has no autocomplete
    expect(find("input[name='password']", visible: false)['autocomplete']).to eq 'off'

    fill_modal(user_attrs)

    expect do
      click_button('Save', visible: false)
      expect(page).to have_text(user_attrs[:username])
    end.to change { User::Human.count }.by 1

    logout
  end

  private

  def fill_modal(user_attrs)
    within('form.ember-view[role="form"]', visible: false) do
      find("input[name='password']", visible: false).set user_attrs[:password]
      find("input[name='username']", visible: false).set(user_attrs[:username])
      find("input[name='surname']", visible: false).set user_attrs[:surname]
      find("input[name='givenname']", visible: false).set user_attrs[:givenname]
    end
  end
end
