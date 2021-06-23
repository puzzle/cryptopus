# frozen_string_literal: true

require 'spec_helper'


describe 'Settings', type: :system, js: true do
  include SystemHelpers

  it 'adjusts settings' do
    allow(GeoIp).to receive(:activated?).and_return(true)

    login_as_user(:admin)

    visit('/admin/settings')

    find('#setting-countries-whitelist-dropdown', visible: false).find(
      'input.ember-power-select-trigger-multiple-input', visible: false
    ).click
    first('ul.ember-power-select-options > li', visible: false).click

    ip_whitelist_input = find(
      '#setting-ip-whitelist-dropdown .ember-power-select-trigger-multiple-input', visible: false
    )
    ip_whitelist_input.click
    ip_whitelist_input.set('192.168.2.1')

    first('ul.ember-power-select-options > li', visible: false).click

    expect(page).to have_css('li.ember-power-select-multiple-option', exact_text: '× 192.168.2.1')

    logout
  end
end
