# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LdapUserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper

  setup :enable_ldap

  test 'login as ldap user' do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')
    user_bob.update_attribute(:uid, 42)

    # Mock
    LdapConnection.any_instance.expects(:login)
                  .with('bob', 'password')
                  .returns(true)
    LdapConnection.any_instance.expects(:ldap_info).twice

    # login
    login_as('bob')
    assert request.fullpath, teams_path
  end

  test 'ldap login with wrong password' do
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')
    user_bob.update_attribute(:uid, 42)

    LdapConnection.any_instance.expects(:login)
                  .with('bob', 'wrong_password')
                  .returns(false)

    login_as('bob', 'wrong_password')
    assert_includes flash[:error], 'Authentication failed'
  end
end
