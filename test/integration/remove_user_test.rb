# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class RemoveUserTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'do not display remove button' do
    login_as('admin')
    get admin_users_path
    assert_select 'a[href="/en/admin/users/#{session[:user_id]}"]', false, "Delete button should not exist"
  end
end