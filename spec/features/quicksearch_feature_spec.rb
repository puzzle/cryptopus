# frozen_string_literal: true
#
# #  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
# #  Cryptopus and licensed under the Affero General Public License version 3 or later.
# #  See the COPYING file at the top-level directory or at
# #  https://github.com/puzzle/cryptopus.
#
# require 'capybara/rails'
# require 'rails_helper'
# describe QuickSearchFeature do
#   include Feature do::FeatureHelper
#   include Capybara::DSL
#
#   it 'search with not available keyword does not show any results' do
#     login_as_user(:bob)
#     page.must_have_selector('.form-group.search')
#
#     fill_in 'q', with: 'lkj'
#     assert_not(page.has_css?('li.result'))
#   end
#
#   it 'shows password after clicking on password field' do
#     login_as_user(:bob)
#     page.must_have_selector('.form-group.search')
#
#     fill_in 'q', with: 'account1'
#     page.must_have_selector('.account-entry')
#     all('.account-entry')[0].click
#     page.must_have_selector('.password-show', visible: true)
#     all('.password-show')[0].click
#     page.must_have_selector('.password-show', visible: false)
#   end
#
#   it 'search and access account' do
#     login_as_user(:bob)
#     page.must_have_selector('.form-group.search')
#
#     fill_in 'q', with: 'account1'
#     page.must_have_selector('.account-entry')
#     all('.account-entry')[0].click
#     page.must_have_content('account1')
#   end
#
#   it 'search by get params' do
#     login_as_user(:bob)
#     visit('/search?q=account1')
#
#     page.must_have_selector('.account-entry')
#     all('.account-entry')[0].click
#     page.must_have_content('account1')
#   end
# end
