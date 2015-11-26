require 'test_helper'
class UserTest < ActiveSupport::TestCase

  test 'cannot create second user bob' do
    user = User.new(username: 'bob')
    assert_not user.valid?
    assert_equal [:username], user.errors.keys
  end

  test 'creates user root' do
    User.delete_all
    User.create_root('pw')

    root = User.find_by_uid(0)
    assert_equal 'root', root.username
    assert_equal 'root', root.givenname
    assert_equal '', root.surname
    assert root.auth_db?
  end

  test 'does not create user root if it already exists' do
    assert_raises(ActiveRecord::RecordInvalid) do
      User.create_root('pw')
    end
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

  test 'first invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 0)
    users(:bob).update_attribute(:last_failed_login_attempt_at, nil)

    users(:bob).authenticate('wrong password')

    assert_equal 1, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at
  end

  test 'second invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 1)
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal 2, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at
  end

  test 'third invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 2)
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal 3, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at
  end

  test 'fourth invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 3)
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal 4, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at
  end

  test 'fifth invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 4)
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal 5, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at
  end

  test 'sixt invalid login attempt, lock user' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 5)
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 10.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal 6, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at
  end

  test 'seventh invalid login attempt, lock user' do
    last_failed_attempt = Time.now - 20.seconds
    users(:bob).update_attribute(:failed_login_attempts, 6)
    users(:bob).update_attribute(:last_failed_login_attempt_at, last_failed_attempt)

    users(:bob).authenticate('wrong password')

    assert_equal 6, users(:bob).failed_login_attempts
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
end
