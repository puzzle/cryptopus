# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'capybara/rails'
require 'test_helper'
class QuickSearchFeatureTest < ActionController::TestCase
  include FeatureTest::FeatureHelper
  include Capybara::DSL


 test 'search with not available keyword does not show any results' do
   Capybara.default_driver = :webkit
   Capybara.javascript_driver = :webkit
   login_as_user(:bob)
   within('div.form-group') do
     fill_in 'search_string', :with => 'lkj'
   end
   assert_not(page.has_css?('li.result'))
   logout
 end

 test 'after copy a username or password with the clipboad it shows a message' do
   login_as_user(:bob)

   logout

 end

 test 'show password after clicking on password field' do

 end


end
