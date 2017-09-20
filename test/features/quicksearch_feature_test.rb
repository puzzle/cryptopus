# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'capybara/rails'
require 'test_helper'
class QuickSearchFeatureTest < Capybara::Rails::TestCase
  include FeatureTest::FeatureHelper
  include Capybara::DSL

  test 'search with not available keyword does not show any results' do
    login_as_user(:bob)
    page.must_have_selector('.form-group.search')

    fill_in 'q', with: 'lkj'
    assert_not(page.has_css?('li.result'))
  end

  test 'show password after clicking on password field' do
    login_as_user(:bob)
    page.must_have_selector('.form-group.search')

    fill_in 'q', with: 'account1'
    page.must_have_selector('.account-entry')
    all('.account-entry')[0].click
    page.must_have_selector('.password-show', visible: true)
    all('.password-show')[0].click
    page.must_have_selector('.password-show', visible: false)
  end
end
