# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
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
    fill_in 'search_string', with: 'lkj'
    assert_not(page.has_css?('li.result'))
    logout
  end

  test 'show password after clicking on password field' do
    login_as_user(:bob)
    fill_in 'search_string', with: 'account1'
    page.must_have_selector('.password-show', visible: true)
    first('.password-show').click
    page.must_have_selector('.password-show', visible: false)
  end
end
