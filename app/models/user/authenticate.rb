# encoding: utf-8

#  Copyright (c) 2008-2016, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

module User::Authenticate

  LOCK_TIME_FAILED_LOGIN_ATTEMPT = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
  def locked?
    locked || temporarly_locked?
  end

  def authenticate(password)
    return if locked?
    authenticated = auth_ldap? ? authenticate_ldap(password) : authenticate_db(password)
    if authenticated
      reset_failed_login_attempts
      update_legacy_password(password) if legacy_password?
      true
    else
      update_failed_login_attempts
      false
    end
  end

  def auth_db?
    auth == 'db'
  end

  def auth_ldap?
    auth == 'ldap'
  end

  def unlock
    update_attribute(:locked, false)
    update_attribute(:failed_login_attempts, 0)
  end


  private

  def update_legacy_password(plaintext_password)
    salt = SecureRandom.hex
    update_attribute(:password, "sha512$#{salt}$" + Digest::SHA512.hexdigest(salt+plaintext_password))
  end

  def temporarly_locked?
    locked_until > Time.now if last_failed_login_attempt_at
  end

  def locked_until
    last_failed_login_attempt_at +
      LOCK_TIME_FAILED_LOGIN_ATTEMPT[failed_login_attempts].seconds
  end

  def authenticate_db(plaintext_password)
    return password == CryptUtils.one_way_crypt(plaintext_password) if legacy_password?
    salt = password.split('$')[1]
    password.split('$')[2] == Digest::SHA512.hexdigest(salt+plaintext_password)
  end

  def authenticate_ldap(plaintext_password)
    LdapTools.ldap_login(username, plaintext_password)
  end

  def update_failed_login_attempts
    attempts = failed_login_attempts + 1

    if attempts >= LOCK_TIME_FAILED_LOGIN_ATTEMPT.length
      update_attribute(:locked, true)
    else
      update_attribute(:failed_login_attempts, attempts)
      update_attribute(:last_failed_login_attempt_at, Time.now)
    end
  end

  def reset_failed_login_attempts
    update_attribute(:failed_login_attempts, 0) if failed_login_attempts > 0
  end
end
