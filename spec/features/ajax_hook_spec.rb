# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'rails_helper'

describe 'AjaxHook', type: :feature, js: true do
  include FeatureTest::FeatureHelper
  include Capybara::DSL

  it 'show toggle-admin message' do
    login_as_user('root')
    visit '/admin/users'
    all(:button, 'role-dropdown')[0].click
    click_link('User')
    expect(page).to have_content('admin is now a user')
  end
end
