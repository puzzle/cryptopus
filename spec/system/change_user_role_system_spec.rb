# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe 'ChangeUserRole', type: :system, js: true do
  include SystemHelpers

  it 'is able to update user role' do
    login_as_root

    expect(page).to have_css('pzsh-menu')
    within('pzsh-menu') do
      all('pzsh-menu-dropdown').first.click
    end
    all('pzsh-menu-dropdown-item').first.click

    expect(page).to have_text('Users')
    expect(page).to have_css('table')

    within find('tr', text: 'tux') do
      expect(page).to have_text('Conf Admin')
      find('div.ember-basic-dropdown-trigger').click
      find('li.ember-power-select-option[data-option-index="0"]').click

      expect(page).to have_text('User')
    end
  end
end
