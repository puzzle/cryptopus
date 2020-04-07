# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class CreateTeamTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
include IntegrationTest::AccountTeamSetupHelper

  setup do
    GeoIp.expects(:activated?).returns(false).at_least_once
  end

  test 'bob creates new normal team' do
    # Setup for test
    account = create_team_group_account('bob', 'password')

    # Create account link
    account_path = account_path(account.id)


    # Bob can access team / accounts
    can_access_account(account_path, 'bob')

    # Root can access team / account
    can_access_account(account_path, 'root')

    # Admin can access team / account
    can_access_account(account_path, 'admin')
  end

  test 'bob creates private team' do
    # Setup for test
    account = create_team_group_account_private('bob', 'password')

    # Create account link
    account_path = account_path(account.id)


    # Bob can not access team / accounts
    can_access_account(account_path, 'bob')

    # Admin can not access team / account
    cannot_access_account(account_path, 'admin')
  end

end
