# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'AjaxHook', type: :system, js: true do
  include SystemTest::SystemHelper

  it 'show user has role user message' do
    login_as_user('root')
    visit '/admin/users'
    all(:button, 'role-dropdown')[4].click
    click_link('User')
    expect(page).to have_content('tux is now a user')
  end
end
