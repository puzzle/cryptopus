# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class GroupsFinderTest <  ActiveSupport::TestCase

  test 'teammember finds his groups' do
    groups = groups_finder.find(bob, 'group')
    assert_equal 2, groups.count
    assert_equal 'group1', groups.first.name
    assert_equal 'group2', groups.second.name
  end
  
  test 'teammember does not find a group with invalid query' do
    groups = groups_finder.find(bob, '42group42')
    assert_equal 0, groups.count
  end
  
  test 'non-teammember does not find group' do
    groups = groups_finder.find(alice, 'group2')
    assert_equal 0, groups.count
  end

  test 'only returns groups where alice is member' do
    groups = groups_finder.send(:groups, alice)
    assert_equal 1, groups.count
    assert_equal 'group1', groups.first.name
  end

  private

  def groups_finder
    Finders::GroupsFinder.new
  end

  def alice
    users(:alice)
  end

  def bob
    users(:bob)
  end
end
