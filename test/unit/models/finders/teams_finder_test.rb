# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class GroupsFinderTest <  ActiveSupport::TestCase

  test 'teammember finds his teams' do
    teams = teams_finder.find(bob, 'team')
    assert_equal 2, teams.count
    assert_equal 'team1', teams.first.name
    assert_equal 'team2', teams.second.name
  end
  
  test 'teammember does not find a team with invalid query' do
    teams = teams_finder.find(bob, '42team42')
    assert_equal 0, teams.count
  end
  
  test 'non-teammember does not find team' do
    teams = teams_finder.find(alice, 'team2')
    assert_equal 0, teams.count
  end

  private

  def teams_finder
    Finders::TeamsFinder.new
  end

  def alice
    users(:alice)
  end

  def bob
    users(:bob)
  end
end
