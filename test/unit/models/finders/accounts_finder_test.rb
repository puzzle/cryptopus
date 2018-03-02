# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountsFinderTest < ActiveSupport::TestCase

  test 'teammember finds his accounts' do
    accounts = accounts_finder.find(bob, 'account')
    assert_equal 2, accounts.count
    assert_equal 'account2', accounts.first.accountname
    assert_equal 'account1', accounts.second.accountname
  end
  
  test 'teammember finds his accounts by tag' do
    accounts = accounts_finder.find_by_tag(bob, 'tag')
    assert_equal 1, accounts.count
    assert_equal 'account2', accounts.first.accountname
  end
  
  test 'teammember does not find an account with invalid query' do
    accounts = accounts_finder.find(bob, '42account42')
    assert_equal 0, accounts.count
  end
  
  test 'teammember does not find an account with invalid tag' do
    accounts = accounts_finder.find_by_tag(bob, 'tag77')
    assert_equal 0, accounts.count
  end
  
  test 'non-teammember does not find account' do
    accounts = accounts_finder.find(alice, 'account2')
    assert_equal 0, accounts.count
  end
  
  test 'non-teammember does not find account by tag' do
    accounts = accounts_finder.find_by_tag(alice, 'tag')
    assert_equal 0, accounts.count
  end

  test 'only returns accounts where alice is member' do
    accounts = accounts_finder.send(:accounts, alice)
    assert_equal 1, accounts.count
    assert_equal 'account1', accounts.first.accountname
  end

  private

  def accounts_finder
    Finders::AccountsFinder.new
  end

  def alice
   users(:alice)
  end

  def bob
    users(:bob)
  end
end
