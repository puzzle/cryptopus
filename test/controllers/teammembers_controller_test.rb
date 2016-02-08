# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class TeammembersControllerTest < ActionController::TestCase
  include ControllerTest::DefaultHelper

  test 'cannot remove admin from non private team' do
    login_as(:alice)
    assert_difference('Teammember.count', 0) do
      delete :destroy, team_id: teams(:team1),id: teammembers(:team1_admin)
    end
  end

  test 'remove teammember from team' do
    login_as(:alice)
    assert_difference('Teammember.count', -1) do
      delete :destroy, team_id: teams(:team1),id: teammembers(:team1_bob)
    end
  end
end