# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
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

  test 'authenticates bob' do
    assert users(:bob).authenticate('password')
  end

  test 'authentication invalid if wrong password' do
    assert_not users(:bob).authenticate('wrong')
  end

  test 'updates bobs user password' do
    bob = users(:bob)
    decrypted_private_key = bob.decrypt_private_key('password')
    bob.update_password('password', 'new')

    assert_not users(:bob).authenticate('password')
    assert users(:bob).authenticate('new')
    assert_equal decrypted_private_key, bob.decrypt_private_key('new')
  end

  test 'update private key if legacy private key' do
    bob = users(:bob)
    decrypted_private_key = bob.decrypt_private_key('password')
    bob.update_attribute(:private_key, legacy_encrypt_private_key(decrypted_private_key, 'password'))

    assert_equal decrypted_private_key, bob.decrypt_private_key('password')
    assert_not bob.legacy_private_key?
  end

  test 'increasing of failed login attempts and it\'s defined delays' do
    bob = users(:bob)

    locktimes = User::Authenticate::LOCK_TIME_FAILED_LOGIN_ATTEMPT
    assert_equal 10, locktimes.count
    locktimes.each_with_index do |timer, i|
      attempt = i + 1

      bob.update_attribute(:failed_login_attempts, attempt)
      last_failed_login_time = Time.now.utc - (locktimes[attempt].seconds)
      bob.update_attribute(:last_failed_login_attempt_at, last_failed_login_time)

      assert_not bob.reload.send(:temporarly_locked?), 'bob shouldnt be locked temporarly'

      bob.authenticate('wrong password')

      return if attempt == locktimes.count - 1

      assert_equal attempt + 1, bob.failed_login_attempts
      assert last_failed_login_time < bob.reload.last_failed_login_attempt_at
    end
  end

  test 'valid login attempt while user is temporarly locked' do
    users(:bob).update_attribute(:failed_login_attempts, 8)
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    assert_nil users(:bob).authenticate('password')
  end

  test 'tenth invalid login attempt locks user' do
    last_failed_attempt = Time.now - 240.seconds
    users(:bob).update_attribute(:failed_login_attempts, 9)
    users(:bob).update_attribute(:last_failed_login_attempt_at, last_failed_attempt)

    users(:bob).authenticate('wrong password')

    assert_equal 9, users(:bob).failed_login_attempts
    assert users(:bob).locked
    assert_equal last_failed_attempt, users(:bob).last_failed_login_attempt_at
  end

  test 'clear failed login attempts' do
    users(:bob).update_attribute(:failed_login_attempts, 5)

    users(:bob).authenticate('password')

    assert_equal users(:bob).failed_login_attempts, 0
  end

  test 'unlock user' do
    users(:bob).update_attribute(:locked, true)
    users(:bob).update_attribute(:failed_login_attempts, 3)

    users(:bob).unlock

    assert_not users(:bob).locked?
    assert_equal 0, users(:bob).failed_login_attempts
  end

  test 'user locked' do
    users(:bob).update_attribute(:locked, true)

    assert users(:bob).locked?
  end

  test 'user not locked' do
    users(:bob).update_attribute(:locked, false)

    assert_not users(:bob).locked?
  end

  test 'user locked if temporarly locked' do
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now)
    users(:bob).update_attribute(:failed_login_attempts, 3)

    assert users(:bob).locked?
  end

  test 'only returns accounts where bob is member' do
    accounts = users(:alice).accounts
    assert_equal 1, accounts.count
    assert_equal 'account1', accounts.first.accountname
  end

  test 'create user from ldap' do
    username = 'bob'
    LdapTools.expects(:get_uid_by_username).returns(42)
    LdapTools.expects(:get_ldap_info).with('42', 'givenname').returns("bob")
    LdapTools.expects(:get_ldap_info).with('42', 'sn').returns("test")

    user = User.send(:create_from_ldap, username, 'password')

    assert_equal username, user.username
    assert_equal 42, user.uid
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
    enable_ldap_auth

    LdapTools.expects(:ldap_login).with('nobody', 'password').returns(false)
    User.expects(:create_from_ldap).never

    user = User.find_or_import_from_ldap('nobody', 'password')

    assert_nil user
  end

  test 'does not return user if user not exists in db and ldap disabled' do
    LdapTools.expects(:ldap_login).never

    user = User.find_or_import_from_ldap('nobody', 'password')
    assert_nil user
  end

  test 'imports and creates user from ldap' do
    enable_ldap_auth
    LdapTools.expects(:ldap_login).with('nobody', 'password').returns(true)
    User.expects(:create_from_ldap).once

    user = User.find_or_import_from_ldap('nobody', 'password')

    assert_nil user
  end

  test 'admin cannot disempower himself' do
    non_private_team = Fabricate(:non_private_team)
    admin = users(:admin)
    private_key = decrypt_private_key(admin)

    assert_raise RuntimeError do
      admin.toggle_admin(admin, private_key)
    end

    admin.reload
    assert admin.admin?
    assert non_private_team.teammember?(admin.id)
  end

  test 'non admin user cannot empower/disempower someone else' do
    private_team = Fabricate(:private_team)
    bob = users(:bob)
    alice = users(:alice)
    private_key = decrypt_private_key(alice)

    assert_raise RuntimeError do
      bob.toggle_admin(alice, private_key)
    end

    bob.reload
    assert_not bob.admin?
    assert_not private_team.teammember?(bob.id)
  end

  test 'bob cannot empower himself' do
    private_team = Fabricate(:private_team)
    bob = users(:bob)
    private_key = decrypt_private_key(bob)

    exception = assert_raises(Exception) do
      bob.toggle_admin(bob, private_key)
    end
    assert_equal 'user is not allowed to empower/disempower this user', exception.message

    bob.reload
    assert_not bob.admin?
    assert_not private_team.teammember?(bob.id)
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
    user = users(:bob)
    user.update_attribute(:auth, 'ldap')

    LdapTools.stubs(:ldap_login).returns(true)

    assert_not user.recrypt_private_key!('new_password', 'wrong_old_password')

    assert_match /Your OLD password was wrong/, user.errors.messages[:base][0]
  end

  test 'new error on user if wrong new password at private_key recryption' do
    user = users(:bob)
    assert_not user.recrypt_private_key!('worong_new_password', 'password')

    assert_match /Your NEW password was wrong/, user.errors.messages[:base][0]
  end


  test 'root can not be disempowered' do
    root = users(:root)
    root.update_attributes(admin: true)

    assert_raise "root can not be disempowered" do
      root.send(:disempower)
    end
  end
  
  test 'updates legacy password on db user' do
    bob = users(:bob)
    bob.update_attributes(password: '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8')
    assert bob.legacy_password?
    bob.authenticate('password')
    assert_not bob.legacy_password?
  end

  test 'does not update legacy password on login if ldap user' do
    bob = users(:bob)
    bob.update_attributes(auth: 'ldap')
    bob.authenticate('password')
    assert_not bob.legacy_password?
  end

  private
  def enable_ldap_auth
    Setting.find_by(key: 'ldap_enable').update_attributes(value: true)
  end

end
