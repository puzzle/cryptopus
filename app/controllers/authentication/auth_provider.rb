# frozen_string_literal: true

class Authentication::AuthProvider

  def initialize(username: nil, password: nil)
    @authenticated = false
    @username = username
    @password = password
  end

  def authenticate!
    return false unless preconditions?

    salt = user.password.split('$')[1]
    authenticated = user.password.split('$')[2] == Digest::SHA512.hexdigest(salt + password)

    add_error('flashes.session.wrong_password') unless authenticated

    brute_force_detector.update(authenticated)
    authenticated
  end

  def brute_force_detector
    @brute_force_detector ||= Authentication::BruteForceDetector.new(user)
  end

  def find_or_create_user
    User.find_by(username: username.strip)
  end

  def update_user_info(remote_ip)
    user.update(last_login_from: remote_ip, last_login_at: Time.zone.now)
  end

  def errors
    @errors ||= []
  end

  def user
    @user ||= find_or_create_user
  end

  private

  attr_accessor :authenticated
  attr_reader :username, :password

  def preconditions?
    if params_present? && valid_username? && user.present?
      return true
    end

    add_error('flashes.session.wrong_password')
    false
  end

  def params_present?
    username.present? && password.present?
  end

  def valid_username?
    username.strip =~ /^([a-zA-Z]|\d)+[-]?([a-zA-Z]|\d)*[^-]$/
  end

  def add_error(msg_key)
    errors << I18n.t(msg_key)
  end
end
