# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Admin::UsersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper
  
  test 'admin empowers user' do
    teammembers(:team1_bob).destroy
    bob = users(:bob)

    login_as(:admin)
    xhr :patch, :toggle_admin, user_id: bob

    bob.reload
    assert bob.admin?
    assert bob.teammembers.find_by(team_id: teams(:team1))
  end
  
  test 'admin disempowers user' do
    teammembers(:team1_bob).destroy
    bob = users(:bob)

    login_as(:admin)
    xhr :patch, :toggle_admin, user_id: bob
    bob.reload
    xhr :patch, :toggle_admin, user_id: bob
    bob.reload

    assert_not bob.admin?
    assert_not bob.teammembers.find_by(team_id: teams(:team1))
  end
end
