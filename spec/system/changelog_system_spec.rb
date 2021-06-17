# frozen_string_literal: true

require 'spec_helper'

describe 'Changelog', type: :system, js: true do
  include SystemHelpers

  it 'opens modal and renders content' do
    login_as_root

    expect(page).to have_selector('.footer', visible: true)

    within('.footer') do
      all('pzsh-footer-link').first.click
    end

    expect(page).to have_selector('div.modal-dialog', visible: true)

    within('div.modal') do
      expect(page).to have_selector('div.modal-header', visible: true)
      expect(page).to have_content 'Cryptopus Changelog'
      expect(page).to have_content 'Version 3.7'

      close_btn = find(:button, 'Close')
      execute_script('arguments[0].scrollIntoView(true)', close_btn)
      close_btn.click
    end

    expect(page).not_to have_selector 'div.modal-dialog'
  end
end
