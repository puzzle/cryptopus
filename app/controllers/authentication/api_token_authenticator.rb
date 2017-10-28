class ApiTokenAuthenticator

  def initialize(headers)
    @authenticated = false
    @headers = headers
  end

  def auth!
    return false unless preconditions?
    return false if user_locked?

    authenticated = user_auth!

    unless authenticated
      add_error('flashes.logins.wrong_password')
    end

    brute_force_detector.update(authenticated)
    authenticated
  end

end
