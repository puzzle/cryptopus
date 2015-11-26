module User::Authenticate

  LOCK_TIME_FAILED_LOGIN_ATTEMPT = [0, 0, 0, 3, 5, 10, 15]
  def locked?
    read_attribute(:locked) || temporarly_locked?
  end

  def authenticate(password)
    return if locked?
    if self.auth_ldap?
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


  private
    def temporarly_locked?
      last_failed_attempt = self.last_failed_login_attempt_at
      if last_failed_attempt
        failed_attempts = self.failed_login_attempts
        locked_until = last_failed_attempt.to_time + LOCK_TIME_FAILED_LOGIN_ATTEMPT[failed_attempts].seconds
        locked_until > Time.now
      end
    end

    def authenticate_db(password)
      self.password == CryptUtils.one_way_crypt(password)
    end

    def authenticate_ldap(password)
      LdapTools.ldap_login(username, password)
    end

    def update_failed_login_attempts
      attempts = self.failed_login_attempts + 1

      if attempts >= LOCK_TIME_FAILED_LOGIN_ATTEMPT.length
        self.update_attribute(:locked, true)
        return
      end

      self.update_attribute(:failed_login_attempts, attempts)
      self.update_attribute(:last_failed_login_attempt_at, Time.now)
    end

    def reset_failed_login_attempts
      self.update_attribute(:failed_login_attempts, 0) if self.failed_login_attempts > 0
    end
end