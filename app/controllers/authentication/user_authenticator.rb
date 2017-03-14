require_relative 'authenticators/user_password.rb'

class Authentication::UserAuthenticator

  def initialize(params)
    @authenticated = false
    @params = params
  end

  def password_auth!
    return false unless preconditions?
    return false if user_locked?

    unless @authenticated = authenticator.auth!
      add_error('flashes.logins.wrong_password')
    end

    brute_force_detector.update(@authenticated)
    @authenticated
  end

  def api_key_auth!
    raise 'not yet implemented'
  end

  def errors
    @errors ||= []
  end

  def user
    authenticator.user
  end

  private

  def authenticator
    @authenticator ||=
      ::UserPassword.new(@params)
  end

  def brute_force_detector
    @brute_force_detector ||=
     Authentication::BruteForceDetector.new(user)
  end

  def preconditions?
    if params_present? && user.present?
      return true
    end
    add_error('flashes.logins.wrong_password')
    false
  end

  def params_present?
    authenticator.params_present?
  end

  def user_locked?
    unless brute_force_detector.locked?
      return false
    end
    add_error('flashes.logins.locked')
    true
  end

  def add_error(msg_key)
    errors << I18n.t(msg_key)
  end

end
