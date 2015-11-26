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
    User.create_root('pw')

    number_of_roots = User.where(username: 'root')
    assert_equal 1, number_of_roots.count
  end

  test 'returns true bob authentication valid' do
    assert users(:bob).authenticate('password')
  end

  test 'returns false if invalid password' do
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
    attempts = users(:bob).failed_login_attempts
    users(:bob).update_attribute(:last_failed_login_attempt_at, nil)

    users(:bob).authenticate('wrong password')

    assert_equal attempts + 1, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at.to_time
  end

  test 'second invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 1)
    attempts = users(:bob).failed_login_attempts
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal attempts + 1, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at.to_time
  end

  test 'third invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 2)
    attempts = users(:bob).failed_login_attempts
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal attempts + 1, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at.to_time
  end

  test 'fourth invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 3)
    attempts = users(:bob).failed_login_attempts
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal attempts + 1, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at.to_time
  end

  test 'fifth invalid login attempt' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 4)
    attempts = users(:bob).failed_login_attempts
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 5.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal attempts + 1, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at.to_time
  end

  test 'sixt invalid login attempt, lock user' do
    time = Time.now
    users(:bob).update_attribute(:failed_login_attempts, 5)
    attempts = users(:bob).failed_login_attempts
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now - 10.seconds)

    users(:bob).authenticate('wrong password')

    assert_equal attempts + 1, users(:bob).failed_login_attempts
    assert time <= users(:bob).last_failed_login_attempt_at.to_time
  end

  test 'seventh invalid login attempt, lock user' do
    last_failed_attempt = Time.now - 20.seconds
    users(:bob).update_attribute(:failed_login_attempts, 6)
    attempts = users(:bob).failed_login_attempts
    users(:bob).update_attribute(:last_failed_login_attempt_at, last_failed_attempt)

    users(:bob).authenticate('wrong password')

    assert_equal attempts, users(:bob).failed_login_attempts
    assert users(:bob).locked
    assert_equal last_failed_attempt, users(:bob).last_failed_login_attempt_at.to_time
  end

  test 'clear failed login attempts' do
    users(:bob).update_attribute(:failed_login_attempts, 5)

    users(:bob).authenticate('password')

    assert_equal users(:bob).failed_login_attempts, 0
  end

  test 'unlock user' do
    users(:bob).update_attribute(:locked, true)

    users(:bob).unlock

    assert_equal users(:bob).locked, false
  end

  test 'user locked if locked' do
    users(:bob).update_attribute(:locked, true)

    locked = users(:bob).locked?

    assert locked
  end

  test 'user not locked not locked' do
    users(:bob).update_attribute(:locked, false)

    locked = users(:bob).locked?

    assert_not locked
  end

  test 'user locked if locking time is not over' do
    users(:bob).update_attribute(:last_failed_login_attempt_at, Time.now)
    users(:bob).update_attribute(:failed_login_attempts, 3)

    locked = users(:bob).locked?

    assert locked
  end
end
