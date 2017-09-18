# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Team::GroupsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'listing all groups of a choosen team' do
    login_as(:bob)
    team = teams(:team1)

    get :index, params: { team_id: team }, xhr: true
    groups = JSON.parse(response.body)['data']['groups'][0]['name']

    assert_equal groups, 'group1'
  end
end
