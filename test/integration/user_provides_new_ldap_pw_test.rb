require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

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
    assert_select "div#hidden_username", {text: "test"}
    assert_select "div#hidden_password", {text: "password"}
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
    login_as('root')
    bobs_user_id = users(:bob).id
    recrypt_id = Recryptrequest.find_by_user_id(bobs_user_id).id
    post admin_recryptrequest_path(recrypt_id), _method: 'delete'
    logout
    login_as('bob', 'newPassword')

    #Test if user could see his account(he should see now)
    get account_path
    assert_select "div#hidden_username", {text: "test"}
    assert_select "div#hidden_password", {text: "password"}
  end
end
