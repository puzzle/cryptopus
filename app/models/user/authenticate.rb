module User::Authenticate

  LOCK_TIME_FAILED_LOGIN_ATTEMPT = [0, 0, 0, 3, 5, 10, 15]
  def locked?
    locked || temporarly_locked?
  end

  def authenticate(password)
    return if locked?
    if auth_ldap?
      authenticated = authenticate_ldap(password)
    else
      authenticated = authenticate_db(password)
    end
    if authenticated
      reset_failed_login_attempts
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
    def temporarly_locked?
      locked_until > Time.now if last_failed_login_attempt_at
    end
    
    def locked_until
      last_failed_login_attempt_at +
        LOCK_TIME_FAILED_LOGIN_ATTEMPT[failed_login_attempts].seconds
    end

    def authenticate_db(plaintext_password)
      password == CryptUtils.one_way_crypt(plaintext_password)
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
