# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'AjaxHook', type: :system, js: true do
  include SystemHelpers

  it 'show user has role user message' do
    login_as_root
    visit admin_users_path
    all(:button, 'role-dropdown')[4].click
    click_link('User')
    within(find('tr', :text => 'Tux')) do
      expect(page).to have_text('User')
    end
  end
end
