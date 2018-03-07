# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class GroupsFinderTest <  ActiveSupport::TestCase

  test 'teammember finds his groups' do
    groups = find(Group.all, 'group1')
    assert_equal 1, groups.count
    assert_equal 'group1', groups.first.name
  end
  
  test 'teammember does not find a group with invalid query' do
    groups = find(Group.all, '42group42')
    assert_equal 0, groups.count
  end
  
  private

  def find(groups, query)
    Finders::GroupsFinder.new(groups, query).apply
  end
end
