# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
class LdapUserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'login as ldap user' do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')

    # Mock
    LdapTools.stubs(:ldap_login).returns(true)
    LdapTools.stubs(:get_ldap_info).with(user_bob.uid, 'givenname').returns('Bob')
    LdapTools.stubs(:get_ldap_info).with(user_bob.uid, 'sn').returns('test')

    # login
    login_as('bob')
    assert request.fullpath, teams_path
  end

  test 'ldap login with wrong password' do
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')
    login_as('bob', 'wrong_password')
    assert_includes flash[:error], 'Authentication failed'
  end
end
