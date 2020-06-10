# frozen_string_literal: true

class Authentication::UserAuthenticator::Db < Authentication::UserAuthenticator

  def authenticate!(allow_root: false)
    return false if allow_root && username != 'root'
    return false if !allow_root && username == 'root'
    return false unless preconditions?

    authenticated = user.authenticate_db(password)

    brute_force_detector.update(authenticated)
    authenticated
  end

  def authenticate_by_headers!
    authenticate!
  end

  def update_user_info(remote_ip)
    super(last_login_from: remote_ip)
  end

  def login_path
    session_new_path
  end

  private

  def find_or_create_user
    User.find_by(username: username.strip)
  end
end
