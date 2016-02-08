# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class Api::TeamsControllerTest < ActionController::TestCase

  include ControllerTest::DefaultHelper

  test 'returns teammember candidates for new team' do
    login_as(:admin)
    team = Team.create(users(:admin), {name: 'foo'})

    get :teammember_candidates, id: team

    candidates = JSON.parse(response.body)[1]

    assert_equal 2, candidates.size
    assert candidates.any? {|c| c['label'] == 'Alice test' }
    assert candidates.any? {|c| c['label'] == 'Bob test' }
  end
end
