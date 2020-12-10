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
      when 'openid-connect'
        Authentication::UserAuthenticator::Oidc.new(params)
      end
    end
  end

  def initialize(username: nil, password: nil, session: nil)
    @authenticated = false
    @username = username
    @password = password
    @session = session
    @allow_root = false
  end

  def authenticate!(_allow_root: false, _allow_api: false)
    raise NotImplementedError, 'implement in subclass'
  end

  def authenticate_by_headers!
    raise NotImplementedError, 'implement in subclass'
  end

  def find_or_create_user
    raise NotImplementedError, 'implement in subclass'
  end

  def user
    @user ||= find_or_create_user
  end

  def login_path
    session_new_path
  end

  def update_user_info(remote_ip)
    attrs = { last_login_from: remote_ip }
    attrs[:last_login_at] = Time.zone.now
    attrs.merge(updatable_user_attrs) unless root_user?
    user.update(attrs)
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
    params_present? &&
      valid_username? &&
      root_and_allowed? &&
      user.present? &&
      no_brute_force_lock?
  end

  def no_brute_force_lock?
    !brute_force_detector.locked?
  end

  def root_and_allowed?
    root_user? && @allow_root
  end

  def params_present?
    username.present? && password.present?
  end

  def valid_username?
    username.strip =~ /^([a-zA-Z]|\d)+[-]?([a-zA-Z]|\d)*[^-]$/
  end

end
