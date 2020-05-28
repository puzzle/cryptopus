# frozen_string_literal: true

class Authentication::UserAuthenticator::Db < Authentication::UserAuthenticator

  def authenticate!
    return false if username == 'root'
    return false unless preconditions?
    return false if brute_force_detector.locked?

    authenticated = user.authenticate_db(password)

    brute_force_detector.update(authenticated)
    authenticated
  end

  def find_or_create_user
    User.find_by(username: username.strip)
  end

  def update_user_info(remote_ip)
    super(last_login_from: remote_ip)
  end

  def login_path
    session_new_path
  end

  def user_logged_in?(session)
    session[:user_id].present? && session[:private_key].present?
  end

  private

  attr_accessor :authenticated
  attr_reader :username, :password

  def brute_force_detector
    @brute_force_detector ||= Authentication::BruteForceDetector.new(user)
  end

  def preconditions?
    params_present? && valid_username? && user.present?
  end
end
