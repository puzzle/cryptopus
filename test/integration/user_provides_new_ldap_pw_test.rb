# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'
require 'test/unit'

class UserProvidesNewLdapPwTest < ActionDispatch::IntegrationTest
  include IntegrationTest::AccountTeamSetupHelper
  include IntegrationTest::DefaultHelper

  setup :enable_ldap

  test 'Bob provides new ldap password and remembers old password' do
    # Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')
    user_bob.update_attribute(:ldap_uid, 42)

    # Method call expectations
    LdapConnection.any_instance.expects(:ldap_info)
      .times(4)

    LdapConnection.any_instance.expects(:login)
      .with('bob', any_of('password', 'newPassword'))
      .returns(true)
      .times(4)
    # Calls login method
    # 2 times with login as and
    # 2 times in recryptrequests_controller

    account_path = get_account_path

    login_as('bob')

    # Recrypt
    post recryptrequests_recrypt_path, params: { new_password: 'newPassword', old_password: 'password' }
    logout

    login_as('bob', 'newPassword')

    # Test if Bob can see his account
    get account_path
    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end

  test "Bob provides new ldap password and doesn't remember his old password" do
    # Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attributes(auth: 'ldap')
    user_bob.update_attribute(:ldap_uid, 42)

    # Method call expectations
    LdapConnection.any_instance.expects(:ldap_info)
      .times(4)

    LdapConnection.any_instance.expects(:login)
      .with('bob', any_of('password', 'newPassword'))
      .returns(true)
      .times(3)
    # Calls login method
    # 2 times with login as and
    # 1 time in recryptrequests_controller

    account_path = get_account_path

    login_as('bob')

    # Recrypt
    post recryptrequests_recrypt_path, params: { forgot_password: true, new_password: 'newPassword' }

    login_as('admin')
    bobs_user_id = users(:bob).id
    recrypt_id = Recryptrequest.find_by_user_id(bobs_user_id).id
    post admin_recryptrequest_path(recrypt_id), params: { _method: 'delete' }

    # Test if user could see his account(he should see now)
    login_as('bob', 'newPassword')
    get account_path
    assert_select "input#cleartext_username", {value: "test"}
    assert_select "input#cleartext_password", {value: "password"}
  end

  test 'Bob provides new ldap password and entered wrong old password' do
    # Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')
    user_bob.update_attribute(:ldap_uid, 42)

    # Method call expectations
    LdapConnection.any_instance.expects(:ldap_info)
      .times(2)

    LdapConnection.any_instance.expects(:login)
      .with('bob', any_of('password', 'newPassword'))
      .returns(true)
      .times(3)
    # Calls login method
    # 2 times with login as and
    # 1 time in recryptrequests_controller

    login_as('bob')

    # Recrypt
    post recryptrequests_recrypt_path, params: { new_password: 'newPassword', old_password: 'wrong_password' }

    # Test if user got error messages
    assert_match 'Your OLD password was wrong', flash[:error]
  end

  test 'Bob provides new ldap password and entered wrong new password' do
    # Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')
    user_bob.update_attribute(:ldap_uid, 42)

    # Method call expectations
    LdapConnection.any_instance.expects(:ldap_info)
      .times(2)

    LdapConnection.any_instance.expects(:login)
      .with('bob', any_of('password', 'newPassword'))
      .returns(true)

    # Test if Bob can see his account (should not)
    # cannot_access_account(get_account_path, 'bob')

    login_as('bob')

    # Recrypt
    LdapConnection.any_instance.expects(:login)
      .with('bob', 'wrong_password')
      .returns(false)

    post recryptrequests_recrypt_path, params: { new_password: 'wrong_password' }

    # Test if user got error messages
    assert_match 'Your NEW password was wrong', flash[:error]
  end

  test 'Bob provides new ldap password over recryptrequest and entered wrong new password' do
    # Prepare for Test
    user_bob = users(:bob)
    user_bob.update_attribute(:auth, 'ldap')
    user_bob.update_attribute(:ldap_uid, 42)

    # Method call expectations
    LdapConnection.any_instance.expects(:ldap_info)
      .times(2)

    LdapConnection.any_instance.expects(:login)
      .with('bob', 'password')
      .returns(true)

    # Test if Bob can see his account (should not)
    # cannot_access_account(get_account_path, 'bob')

    login_as('bob')

    #Recrypt
    LdapConnection.any_instance.expects(:login)
      .with('bob', 'wrong_password')
      .returns(false)

    post recryptrequests_recrypt_path, params: { forgot_password: true, new_password: 'wrong_password' }

    # Test if user got error messages
    assert_match 'Your NEW password was wrong', flash[:error]
  end
end
