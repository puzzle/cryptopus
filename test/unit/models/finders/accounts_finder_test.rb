# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountsFinderTest < ActiveSupport::TestCase

  test 'teammember finds his accounts' do
    accounts = find(Account.all, 'account1')
    assert_equal 1, accounts.count
    assert_equal 'account1', accounts.first.accountname
  end
  
  test 'teammember does not find an account with invalid query' do
    accounts = find(Account.all, '42account42')
    assert_equal 0, accounts.count
  end
  
  private

  def find(accounts, query)
    Finders::AccountsFinder.new(accounts, query).apply
  end
end
