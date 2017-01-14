class Authentication::BruteForceDetector

  LOCK_TIME_FAILED_LOGIN_ATTEMPT = [0, 0, 0, 3, 5, 20, 30, 60, 120, 240].freeze

  def initialize(user)
    @user = user
  end

  def locked?
    user.locked? || user_temporarly_locked?
  end

  def update(auth_successful)
    if auth_successful
      reset_failed_login_attempts
    else
      update_failed_login_attempts
    end
  end

  private

  attr_accessor :user

  def user_temporarly_locked?
    user_locked_until > now if user.last_failed_login_attempt_at
  end

  def user_locked_until
    user.last_failed_login_attempt_at +
      LOCK_TIME_FAILED_LOGIN_ATTEMPT[user.failed_login_attempts].seconds
  end

  def update_failed_login_attempts
    attempts = user.failed_login_attempts + 1

    if attempts >= LOCK_TIME_FAILED_LOGIN_ATTEMPT.length
      user.update_attribute(:locked, true)
    else
      user.update_attributes(failed_login_attempts: attempts,
                             last_failed_login_attempt_at: now)
    end
  end

  def now
    DateTime.now.utc
  end

  def reset_failed_login_attempts
    user.unlock if user.failed_login_attempts > 0
  end

end
