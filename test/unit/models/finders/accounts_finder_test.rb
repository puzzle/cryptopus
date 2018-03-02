# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class AccountsFinderTest <  ActiveSupport::TestCase

  test 'only returns accounts where bob is member' do
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
end
