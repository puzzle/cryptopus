module Authenticators
  class Base

    LOCK_TIME_FAILED_LOGIN_ATTEMPT = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze
    def initialize(user, password, opts = {})
      @user = user
      @password = password
      @opts = opts
    end

    def auth!
      return false if user_locked?
      if authenticated?
        reset_failed_login_attempts
        true
      else
        update_failed_login_attempts
        false
      end
    end

    def user_temporarly_locked?
      user_locked_until > Time.now if @user.last_failed_login_attempt_at
    end

    private

    def authenticated?
      raise 'implement in subclass'
    end

    def user_locked?
      @user.locked? || user_temporarly_locked?
    end

    def user_locked_until
      @user.last_failed_login_attempt_at +
        LOCK_TIME_FAILED_LOGIN_ATTEMPT[@user.failed_login_attempts].seconds
    end

    def reset_failed_login_attempts
      @user.update_attribute(:failed_login_attempts, 0) if @user.failed_login_attempts > 0
    end

    def update_failed_login_attempts
      attempts = @user.failed_login_attempts + 1

      if attempts >= LOCK_TIME_FAILED_LOGIN_ATTEMPT.length
        @user.update_attribute(:locked, true)
      else
        @user.update_attribute(:failed_login_attempts, attempts)
        @user.update_attribute(:last_failed_login_attempt_at, Time.now)
      end
    end

  end
end
