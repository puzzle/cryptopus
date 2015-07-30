require 'test_helper'
require 'test/unit'
require 'mocha/test_unit'

class CreateUserTest < ActionDispatch::IntegrationTest
=begin
include AccountTeamSetup
  test 'Bob provides new ldap password and remember his old password' do
    #Prepare for Test
    setup_team_acc('bob', 'password', 'Testteam', 'no description', false, false, 'Testgroup', 'no description', 'Testacc', 'no description', 'account_username', 'account_password')
    user_bob = User.find_by_username('bob')
    user_bob.update_attributes(auth: 'ldap')

    #Mock
    LdapTools.stubs(:ldap_login).returns(true)
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid.to_s, 'givenname').returns('Bob')
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid.to_s, 'sn').returns('test')

    #Login
    login_as('bob', 'newPassword')

    #Get link to Account
    team_id = Team.find_by_name('Testteam').id
    group_id = Group.find_by_name('Testgroup').id
    account_id = Account.find_by_accountname('Testacc').id
    account_link = "/teams/" + team_id.to_s + "/groups" + "/" + group_id.to_s + "/accounts/" + account_id.to_s

    #Test if user could see his account (should not)
    err = assert_raises(RuntimeError) { get account_link }
    assert "Failed to decrypt the group password", err.message

    #Recrypt
    post '/recryptrequests', new_password: 'newPassword', old_password: 'password'
    login_as('bob', 'newPassword')
    #Test if user could see his account(he should see now)
    get account_link
    assert_select "div#hidden_username", {text: "account_username"}
    assert_select "div#hidden_password", {text: "account_password"}
  end

  test "Bob provides new ldap password and doesn't remember his old password" do
    #Prepare for Test
    setup_team_acc('bob', 'password','Testteam', 'no description', false, false, 'Testgroup', 'no description', 'Testacc', 'no description', 'account_username', 'account_password')
    user_bob = User.find_by_username('bob')
    user_bob.update_attributes(auth: 'ldap')

    #Mock
    LdapTools.stubs(:ldap_login).returns(true)
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid.to_s, 'givenname').returns('Bob')
    LdapTools.stubs(:get_ldap_info).with(User.find_by_username('bob').uid.to_s, 'sn').returns('test')

    #Login
    login_as('bob', 'newPassword')

    #Get link to Account
    team_id = Team.find_by_name('Testteam').id
    group_id = Group.find_by_name('Testgroup').id
    account_id = Account.find_by_accountname('Testacc').id
    account_link = "/teams/" + team_id.to_s + "/groups" + "/" + group_id.to_s + "/accounts/" + account_id.to_s

    #Test if user could see his account (should not)
    err = assert_raises(RuntimeError) { get account_link }
    assert "Failed to decrypt the group password", err.message

    #Recrypt
    post '/recryptrequests', recrypt_request: true, new_password: 'newPassword'
    login_as('root', 'password')
    bobs_user_id = User.find_by_username('bob').id.to_s
    recrypt_id = Recryptrequest.find_by_user_id(bobs_user_id).id.to_s
    post 'admin/recryptrequests/' + recrypt_id, _method: 'delete'
    logout
    login_as('bob', 'newPassword')

    #Test if user could see his account(he should see now)
    get account_link
    assert_select "div#hidden_username", {text: "account_username"}
    assert_select "div#hidden_password", {text: "account_password"}
  end
=end
end
