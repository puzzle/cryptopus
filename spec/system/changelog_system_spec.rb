# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'spec_helper'

describe 'Changelog', type: :system, js: true do
  include SystemHelpers

  it 'opens modal and renders content' do
    login_as_root

    within(".footer") do
      all('pzsh-footer-link').first.click
    end

    expect(page).to have_selector('div.modal-dialog', visible: true)

    within('div.modal-dialog') do
      expect(page).to have_selector('div.modal-header', visible: true)
      expect(page).to have_content 'Cryptopus Changelog'

      close_btn = find(:button, 'Close')
      execute_script('arguments[0].scrollIntoView(true)', close_btn)
      close_btn.click
    end

    expect(page).not_to have_selector 'div.modal-dialog'
  end
end
