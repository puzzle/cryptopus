# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::Team::MembersControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'returns team member candidates for new team' do
    login_as(:admin)
    team = Team.create(users(:admin), {name: 'foo'})

    get :candidates, team_id: team

    candidates = JSON.parse(response.body)[1]

    assert_equal 2, candidates.size
    assert candidates.any? {|c| c['label'] == 'Alice test' }
    assert candidates.any? {|c| c['label'] == 'Bob test' }
  end

  test 'returns team members for given team' do
    login_as(:admin)

    team = teams(:team1)
    teammembers(:team1_bob).destroy!

    get :index, team_id: team

    members = JSON.parse(response.body)[1]

    assert_equal 3, members.size
    assert members.any? {|c| c['label'] == 'Root test' }
    assert members.any? {|c| c['label'] == 'Alice test' }
    assert members.any? {|c| c['label'] == 'Admin test' }
  end

end
