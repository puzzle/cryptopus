# frozen_string_literal: true

#  Copyright (c) 2008-2021, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'


describe 'UpdatePasswordModal', type: :system, js: true do
  include SystemHelpers

  let(:password_attrs) do
    { old_pwd: 'password',
      new_pwd1: 'password',
      new_pwd2: 'password' }
  end

  let(:false_password_attrs) do
    { old_pwd: 'falsepassword',
      new_pwd1: 'password',
      new_pwd2: 'badpassword' }
  end

  it 'updates password' do
    login_as_user(:bob)

    visit('/profile')

    # Open modal
    expect(find('button.btn.btn-primary')).to be_present
    manage_pwd_button = find('button.btn.btn-primary', text: 'Manage password')
    expect(manage_pwd_button).to be_present
    manage_pwd_button.click

    expect(find('.modal')).to be_present
    expect(page).to have_button('Save', visible: false)

    fill_modal(password_attrs)
    click_button('Save', visible: false)

    expect(page).to have_text('Successfully changed password.')
  end

  it 'shows error message when inputs are incorrect' do
    login_as_user(:bob)

    visit('/profile')

    # Open modal
    expect(find('button.btn.btn-primary')).to be_present
    manage_pwd_button = find('button.btn.btn-primary', text: 'Manage password')
    expect(manage_pwd_button).to be_present
    manage_pwd_button.click

    expect(find('.modal')).to be_present
    expect(page).to have_button('Save', visible: false)

    # Try with non-matching new passwords
    fill_modal(false_password_attrs)

    expect(page).to have_text("New passwords don't match")

    # Try with false current password
    all('input[name="newPassword1"]').last.set password_attrs[:new_pwd2]
    click_button('Save', visible: false)

    expect(page).to have_text('Wrong password')
  end

  private

  def fill_modal(password_attrs)
    within('div.modal-body') do
      expect(page).to have_css('input', count: 3)
      password_inputs = all('input')

      old_password_input = password_inputs.first
      new_password_input = password_inputs[1]
      confirm_password_input = password_inputs.last

      old_password_input.set password_attrs[:old_pwd]
      new_password_input.set password_attrs[:new_pwd1]
      confirm_password_input.set password_attrs[:new_pwd2]
    end
  end

end
