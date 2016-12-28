require 'test_helper'

class AuthenticatorTest < ActiveSupport::TestCase

  test 'authenticates bob' do
    assert_equal true, Authenticator.authenticate(bob, 'password')
  end

  test 'authentication invalid if wrong password' do
    assert_equal false, Authenticator.authenticate(bob, 'wrong')
  end

  test 'authentication invalid if blank password' do
    assert_equal false, Authenticator.authenticate(bob, '')
  end

  test 'authenticates against ldap' do
    bob.update_attribute(:auth, 'ldap')
    LdapTools.expects(:ldap_login).with('bob', 'ldappw').returns(true)
    assert_equal true, Authenticator.authenticate(bob, 'ldappw')
  end

  test 'doesnt authenticate against ldap' do
    bob.update_attribute(:auth, 'ldap')
    LdapTools.expects(:ldap_login).with('bob', 'wrongldappw').returns(false)
    assert_equal false, Authenticator.authenticate(bob, 'wrongldappw')
  end

  test 'increasing of failed login attempts and it\'s defined delays' do
    locktimes = Authenticators::Base::LOCK_TIME_FAILED_LOGIN_ATTEMPT
    assert_equal 10, locktimes.count
    locktimes.each_with_index do |timer, i|
      attempt = i + 1

      bob.update_attribute(:failed_login_attempts, attempt)
      last_failed_login_time = Time.now.utc - (locktimes[attempt].seconds)
      bob.update_attribute(:last_failed_login_attempt_at, last_failed_login_time)

      authenticator = Authenticators::Db.new(bob, 'wrong password')

      assert_not authenticator.send(:user_temporarly_locked?), 'bob shouldnt be locked temporarly'

      authenticator.auth!

      return if attempt == locktimes.count - 1

      assert_equal attempt + 1, bob.failed_login_attempts
      assert last_failed_login_time.to_i <= bob.reload.last_failed_login_attempt_at.to_i
    end
  end

  test 'tenth invalid login attempt locks user' do
    last_failed_attempt = Time.now - 240.seconds
    bob.update_attribute(:failed_login_attempts, 9)
    bob.update_attribute(:last_failed_login_attempt_at, last_failed_attempt)

    assert_equal false, Authenticator.authenticate(bob, 'wrong password')

    assert_equal 9, bob.failed_login_attempts
    assert bob.locked?
    assert_equal last_failed_attempt, bob.last_failed_login_attempt_at
  end

  test 'clear failed login attempts' do
    bob.update_attribute(:failed_login_attempts, 5)

    assert_equal true, Authenticator.authenticate(bob, 'password')

    assert_equal bob.failed_login_attempts, 0
  end
  
  test 'updates legacy password on db user' do
    bob.update_attributes(password: '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8')
    assert_equal true, bob.reload.legacy_password?
    assert_equal true, Authenticator.authenticate(bob, 'password')
    assert_equal false, bob.legacy_password?
  end
  
  test 'doesnt update legacy password if wrong password' do
    bob.update_attributes(password: '5baa61e4c9b93f3f0682250b6cf8331b7ee68fd8')
    assert_equal true, bob.reload.legacy_password?
    assert_equal false, Authenticator.authenticate(bob, 'wrong password')
    assert_equal true, bob.legacy_password?
  end

  test 'valid login attempt while user is temporarly locked' do
    bob.update_attribute(:failed_login_attempts, 8)
    bob.update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    assert_equal false, Authenticator.authenticate(bob, 'password')
    assert_equal 8, bob.reload.failed_login_attempts
  end

  private
  def bob
    users(:bob)
  end

end
