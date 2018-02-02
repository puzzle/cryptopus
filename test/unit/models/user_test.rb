# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'does not create user without name' do
    user = User.new(username: '')
    assert_not user.valid?
    assert_equal [:username], user.errors.keys
  end

  test 'does not create second user bob' do
    user = User.new(username: 'bob')
    assert_not user.valid?
    assert_equal [:username], user.errors.keys
  end

  test 'updates bobs user password' do
    bob = users(:bob)
    decrypted_private_key = bob.decrypt_private_key('password')
    bob.update_password('password', 'new')

    assert_equal false, users(:bob).authenticate('password')
    assert_equal true, users(:bob).authenticate('new')
    assert_equal decrypted_private_key, bob.decrypt_private_key('new')
  end

  test 'update private key if legacy private key' do
    bob = users(:bob)
    decrypted_private_key = bob.decrypt_private_key('password')
    bob.update_attribute(:private_key, legacy_encrypt_private_key(decrypted_private_key, 'password'))

    assert_equal decrypted_private_key, bob.decrypt_private_key('password')
    assert_not bob.legacy_private_key?
  end

  test 'unlock user' do
    users(:bob).update_attribute(:locked, true)
    users(:bob).update_attribute(:failed_login_attempts, 3)

    users(:bob).unlock

    assert_not users(:bob).locked?
    assert_equal 0, users(:bob).failed_login_attempts
  end

  test 'only returns accounts where bob is member' do
    accounts = users(:alice).accounts
    assert_equal 1, accounts.count
    assert_equal 'account1', accounts.first.accountname
  end

  test 'user locked' do
    users(:bob).update_attribute(:locked, true)

    assert users(:bob).locked?
  end

  test 'user not locked' do
    users(:bob).update_attribute(:locked, false)

    assert_not users(:bob).locked?
  end

  test 'create user from ldap' do
    enable_ldap
    LdapConnection.any_instance.expects(:uidnumber_by_username).returns(42)
    LdapConnection.any_instance.expects(:ldap_info).with(42, 'givenname').returns("bob")
    LdapConnection.any_instance.expects(:ldap_info).with(42, 'sn').returns("test")

    user = User.send(:create_from_ldap, 'bob', 'password')

    assert_equal 'bob', user.username
    assert_equal 42, user.ldap_uid
    assert_equal 'bob', user.givenname
    assert_equal 'test', user.surname
    assert_equal 'ldap', user.auth
  end

  test 'returns user if exists in db' do
    user = User.find_or_import_from_ldap('bob', 'password')
    assert user
    assert_equal 'bob', user.username
  end

  test 'does not return user if user not exists in db and ldap' do
    enable_ldap

    LdapConnection.any_instance.expects(:login).with('nobody', 'password').returns(false)
    User.expects(:create_from_ldap).never

    user = User.find_or_import_from_ldap('nobody', 'password')
    assert_nil user
  end

  test 'does not return user if user not exists in db and ldap disabled' do
    LdapConnection.any_instance.expects(:login).never

    user = User.find_or_import_from_ldap('nobody', 'password')
    assert_nil user
  end

  test 'imports and creates user from ldap' do
    enable_ldap
    LdapConnection.any_instance.expects(:login).with('nobody', 'password').returns(true)
    User.expects(:create_from_ldap)

    user = User.find_or_import_from_ldap('nobody', 'password')

    assert_nil user
  end

  test 'do not destroy user if he is last teammember in any team' do
    soloteam = Fabricate(:private_team)
    user = User.find(soloteam.teammembers.first.user_id)
    assert_raises(Exception) do
      user.destroy!
    end
    assert User.find(user.id)
  end

  test 'new error on user if wrong old password at private_key recryption' do
    enable_ldap
    user = users(:bob)
    user.update_attribute(:auth, 'ldap')

    LdapConnection.any_instance.expects(:login).returns(true)

    assert_not user.recrypt_private_key!('new_password', 'wrong_old_password')

    assert_match(/Your OLD password was wrong/, user.errors.messages[:base][0])
  end

  test 'cannot auth against ldap if ldap disabled' do
    user = users(:bob)
    user.update_attribute(:auth, 'ldap')

    LdapConnection.any_instance.expects(:login).never

    error = assert_raises { user.authenticate('password') }

    assert_equal 'cannot authenticate against ldap since ldap auth is disabled', error.message
  end

  test 'new error on user if wrong new password at private_key recryption' do
    user = users(:bob)
    assert_not user.recrypt_private_key!('worong_new_password', 'password')

    assert_match(/Your NEW password was wrong/, user.errors.messages[:base][0])
  end
  
  test 'account search sequence should not matter' do
    accounts = users(:root).search_accounts('1 acc')
    assert_equal 1, accounts.count
    assert_equal 'account1', accounts.first.accountname
  end
  
  context '#update_role' do
    test 'conf admin can upgrade another user to conf admin' do
      conf_admin = users(:conf_admin)
      private_key = decrypt_private_key(conf_admin)
      bob = users(:bob)

      bob.update_role(conf_admin, :conf_admin, private_key)

      assert bob.conf_admin?
    end

    test 'conf admin can downgrade another conf admin to user' do
      conf_admin = users(:conf_admin)
      private_key = decrypt_private_key(conf_admin)
      bob = users(:bob)

      bob.update_role(conf_admin, :conf_admin, private_key)

      bob.update_role(conf_admin, :user, private_key)

      assert_not bob.conf_admin?
    end

   test 'root can not be disempowered' do
     root = users(:root)
     root.update_attributes(role: :admin)

     assert_raise "root can not be disempowered" do
       root.send(:disempower)
      end
    end
  end

  def non_private_team
    Fabricate(:non_private_team)
  end
end
