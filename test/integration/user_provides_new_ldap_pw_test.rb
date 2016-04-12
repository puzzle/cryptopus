# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class UserProvidesNewLdapPwTest < ActionDispatch::IntegrationTest
include IntegrationTest::AccountTeamSetupHelper
include IntegrationTest::DefaultHelper
  test 'Bob provides new ldap password and remembers old password' do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')

    #Mock
    LdapTools.stubs(:ldap_login).returns(true)
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid, 'givenname').returns('Bob')
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid, 'sn').returns('test')

    #Login
    login_as('bob', 'newPassword')

    #Get path to Account
    account_path = get_account_path

    #Test if Bob can see his account (should not)
    error = assert_raises(RuntimeError) { get account_path }
    assert_includes error.message, "Failed"

    #Recrypt
    post recryptrequests_path, new_password: 'newPassword', old_password: 'password'
    login_as('bob', 'newPassword')

    #Test if Bob can see his account
    get account_path
    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end

  test "Bob provides new ldap password and doesn't remember his old password" do
    #Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attributes(auth: 'ldap')

    #Mock
    LdapTools.stubs(:ldap_login).returns(true)
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid.to_s, 'givenname').returns('Bob')
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid.to_s, 'sn').returns('test')

    #Login
    login_as('bob', 'newPassword')

    #Get link to Account
    account_path = get_account_path

    #Test if user could see his account (should not)
    error = assert_raises(RuntimeError) { get account_path }
    assert_includes error.message, "Failed"

    #Recrypt
    post recryptrequests_path, recrypt_request: true, new_password: 'newPassword'
    login_as('admin')
    bobs_user_id = users(:bob).id
    recrypt_id = Recryptrequest.find_by_user_id(bobs_user_id).id
    post admin_recryptrequest_path(recrypt_id), _method: 'delete'
    logout
    login_as('bob', 'newPassword')

    #Test if user could see his account(he should see now)
    get account_path
    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end
end
