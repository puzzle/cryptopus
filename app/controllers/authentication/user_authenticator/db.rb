# frozen_string_literal: true

class Authentication::UserAuthenticator::Db < Authentication::UserAuthenticator

  def authenticate!(allow_root: false, allow_api: false)
    return false unless preconditions?
    return false if user_forbidden?(allow_root, allow_api)

    authenticated = user.authenticate_db(password)

    brute_force_detector.update(authenticated)
    authenticated
  end

  def authenticate_by_headers!
    authenticate!(allow_api: true)
  end

  def update_user_info(remote_ip)
    super(last_login_from: remote_ip)
  end

  def recrypt_path
    session_new_path
  end

  private

  def user_forbidden?(allow_root, allow_api)
    !allow_root && root_user? || !allow_api && user.is_a?(User::Api)
  end

  # Databse Users can't be created automatically so only find
  def find_or_create_user
    User.find_by(username: username.strip)
  end
end
