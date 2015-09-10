require 'test_helper'
class LdapUserLoginTest < ActionDispatch::IntegrationTest
include IntegrationTest::DefaultHelper
  test 'create new user if first ldap login' do
    # Mock
    LdapTools.stubs(:ldap_login).returns(true)
    LdapTools.stubs(:get_uid_by_username).returns(42)
    LdapTools.stubs(:connect)
    LdapTools.stubs(:get_ldap_info)

    login_as('ldap_user')
    assert request.fullpath, teams_path
    assert User.find_by_username('ldap_user')
  end

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