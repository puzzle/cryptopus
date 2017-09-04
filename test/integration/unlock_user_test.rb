# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class UserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'unlock user' do
    users(:bob).update_attribute(:locked, true)
    :post 
  end
end