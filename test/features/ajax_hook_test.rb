# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'capybara'
require 'test_helper'
class AjaxHookTest < Capybara::Rails::TestCase
  include FeatureTest::FeatureHelper
  include Capybara::DSL

  test 'show toggle-admin message' do
    login_as_user('root')
    visit '/admin/users' 

    page.must_have_selector('.toggle-button')
    first('.toggle-button').click
    page.must_have_content 'admin is no more admin'
  end
end
