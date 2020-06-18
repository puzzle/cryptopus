# frozen_string_literal: true

include Rails.application.routes.url_helpers

class Authentication::UserAuthenticator

  class << self
    def init(params)
      case AuthConfig.provider
      when 'db'
        Authentication::UserAuthenticator::Db.new(params)
      when 'ldap'
        Authentication::UserAuthenticator::Ldap.new(params)
      when 'keycloak'
        Authentication::UserAuthenticator::Sso.new(params)
      end
    end
  end

  def initialize(username: nil, password: nil)
    @authenticated = false
    @username = username
    @password = password
  end

  def authenticate!
    raise NotImplementedError, 'implement in subclass'
  end

  def authenticate_by_headers!
    raise NotImplementedError, 'implement in subclass'
  end

  def find_or_create_user
    raise NotImplementedError, 'implement in subclass'
  end

  def update_user_info(params)
    params[:last_login_at] = Time.zone.now
    user.update(params.compact)
  end

  def user
    @user ||= find_or_create_user
  end

  def login_path
    session_new_path
  end

  def user_logged_in?(session)
    session[:user_id].present?
  end

  def logged_out_path
    session_new_path
  end

  private

  attr_accessor :authenticated
  attr_reader :username, :password

  def root_user?
    username == 'root'
  end

  def brute_force_detector
    @brute_force_detector ||= Authentication::BruteForceDetector.new(user)
  end

  def preconditions?
    params_present? && valid_username? && user.present? &&
      !brute_force_detector.locked?
  end

  def params_present?
    username.present? && password.present?
  end

  def valid_username?
    username.strip =~ /^([a-zA-Z]|\d)+[-]?([a-zA-Z]|\d)*[^-]$/
  end
end
