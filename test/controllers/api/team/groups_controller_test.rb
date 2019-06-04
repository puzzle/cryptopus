# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Team::GroupsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'listing all groups of a given team' do

    login_as(:bob)
    team = teams(:team1)

    get :index, params: { team_id: team }, xhr: true

    groups = JSON.parse(response.body)['data']['groups']

    assert_equal "group1", groups.first['name']

  end
end
