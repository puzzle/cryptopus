# frozen_string_literal: true

include Rails.application.routes.url_helpers

class Authentication::UserAuthenticator

  class << self
    def init(**params)
      case AuthConfig.provider
      when 'db'
        Authentication::UserAuthenticator::Db.new(**params)
      when 'ldap'
        Authentication::UserAuthenticator::Ldap.new(**params)
      when 'openid-connect'
        Authentication::UserAuthenticator::Oidc.new(**params)
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

  def authenticate!(allow_root: false, allow_api: false)
    @allow_root = allow_root
    @allow_api = allow_api
    false
  end

  def authenticate_by_headers!
    authenticate!(allow_api: true)
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
    attrs = { last_login_from: remote_ip,
              last_login_at: Time.zone.now }
    attrs.merge(updatable_user_attrs) unless @user.root?
    user.update(attrs)
  end

  def updatable_user_attrs
    raise NotImplementedError, 'implement in subclass'
  end

  # redirect to session new path if no recrypt feature
  # for given auth provider
  def recrypt_path
    session_new_path
  end

  private

  attr_accessor :authenticated
  attr_reader :username, :password

  def brute_force_detector
    @brute_force_detector ||= Authentication::BruteForceDetector.new(user)
  end

  def preconditions?
    params_present? &&
      valid_username? &&
      user.present? &&
      user_allowed? &&
      no_brute_force_lock?
  end

  def no_brute_force_lock?
    !brute_force_detector.locked?
  end

  def user_allowed?
    if user.is_a?(User::Api)
      @allow_api == true
    elsif user.root?
      @allow_root == true
    else
      true
    end
  end

  def params_present?
    @username.present? && @password.present?
  end

  def valid_username?
    regex = /^([a-zA-Z]|\d)+-?([a-zA-Z]|\d)*[^-]$/
    regex.match?(username.strip)
  end

  def db_authenticator
    ::Authentication::UserAuthenticator::Db.new(username: @username, password: @password)
  end

end
