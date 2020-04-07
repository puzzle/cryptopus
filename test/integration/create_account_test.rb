# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class CreateAccountTest < ActionDispatch::IntegrationTest
  include IntegrationTest::DefaultHelper
  test 'bob creates new account' do
    login_as('bob')

    group = groups(:group1)
    accounts_path = accounts_path(params: { account: {accountname: 'e-mail', cleartext_username: 'bob@test', cleartext_password: 'alice33', group_id: group.id} })

    post accounts_path
    follow_redirect!

    account = group.accounts.find_by_accountname('e-mail')
    assert account

    get account_path(id: account.id)

    assert_select "input#cleartext_username", {value: "bob@test"}
    assert_select "input#cleartext_password", {value: "alice33"}
  end

  test 'alice reads account data' do
    login_as('alice')

    account = accounts(:account1)

    get account_path(id: account.id)

    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end
end
