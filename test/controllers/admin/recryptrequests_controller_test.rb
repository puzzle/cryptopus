# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class Admin::RecryptrequestsControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  def setup
    request.env["HTTP_REFERER"] = 'where_i_came_from'
  end

  test 'could not reset roots password' do
    login_as(:admin)
    root = users(:root)
    root_password = root.password
    post :resetpassword, new_password: 'test', user_id: root.id

    root.reload

    assert_equal root_password, root.password
    assert_redirected_to 'where_i_came_from'
  end
end