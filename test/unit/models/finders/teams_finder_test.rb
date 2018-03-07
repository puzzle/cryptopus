# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class GroupsFinderTest <  ActiveSupport::TestCase

  test 'teammember finds his teams' do
    teams = find(Team.all, 'team1')
    assert_equal 'team1', teams.first.name
  end
  
  test 'teammember does not find a team with invalid query' do
    teams = find(Team.all, '42team42')
    assert_equal 0, teams.count
  end
  
  private

  def find(teams, query)
    Finders::TeamsFinder.new(teams, query).apply
  end
end
