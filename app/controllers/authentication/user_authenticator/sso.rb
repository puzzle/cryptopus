# frozen_string_literal: true

class Authentication::UserAuthenticator::Sso < Authentication::UserAuthenticator

  def authenticate!
    return false unless Keycloak::Client.user_signed_in?(access_token)
    return false unless preconditions?

    true
  end

  def authenticate_by_headers!
    return false unless header_preconditions?

    if user.is_a?(User::Api)
      authenticated = user.authenticate_db(password)
    end
    brute_force_detector.update(authenticated)
    authenticated
  end

  def update_user_info(remote_ip)
    params = { last_login_from: remote_ip }
    params.merge(keycloak_params) unless root_user?
    super(params)
  end

  def login_path
    sso_path
  end

  def user_logged_in?(session)
    session[:user_id].present? && user_allowed?(session)
  end

  def keycloak_login
    Keycloak::Client.url_login_redirect(keycloak_login_url, 'code')
  end

  def   token(params)
    Keycloak::Client.get_token_by_code(params[:code], keycloak_login_url)
  end

  def logged_out_path
    sso_inactive_path
  end

  def recrypt_path
    recrypt_sso_path
  end

  private

  def access_token
    JSON.parse(@cookies.to_hash['keycloak_token'])['access_token']
  end

  def user_allowed?(session)
    session[:username] == 'root' || Keycloak::Client.user_signed_in?(access_token)
  end

  def find_or_create_user
    user = User.find_by(username: username.strip)
    return create_user if user.nil? && Keycloak::Client.user_signed_in?(access_token)

    user
  end

  def header_preconditions?
    headers_present? && user_valid? && !root_user?
  end

  def headers_present?
    username.present? && password.present?
  end

  def user_valid?
    valid_username? && user.present? && !brute_force_detector.locked?
  end

  def keycloak_login_url
    protocol = Rails.application.config.force_ssl ? 'https://' : 'http://'
    protocol + (ENV['RAILS_HOST_NAME'] || 'localhost:3000') + sso_path
  end

  def keycloak_params
    { provider_uid: Keycloak::Client.get_attribute('sub', access_token),
      givenname: Keycloak::Client.get_attribute('given_name', access_token),
      surname: Keycloak::Client.get_attribute('family_name', access_token) }
  end

  def username
    @username ||= Keycloak::Client.get_attribute('preferred_username', access_token)
  end

  def create_user
    provider_uid = Keycloak::Client.get_attribute('sub', access_token)
    pk_secret_base = keycloak_client.find_or_create_pk_secret_base(@cookies)
    User::Human.create(
      username: username,
      givenname: Keycloak::Client.get_attribute('given_name', access_token),
      surname: Keycloak::Client.get_attribute('family_name', access_token),
      provider_uid: provider_uid,
      auth: 'keycloak'
    ) { |u| u.create_keypair(keycloak_client.user_pk_secret(secret: pk_secret_base, cookies: @cookies)) }
  end

  def preconditions?
    params_present? && valid_username? && user.present? &&
      !brute_force_detector.locked?
  end

  def params_present?
    Keycloak::Client.get_attribute('preferred_username', access_token).present?
  rescue JWT::DecodeError
    false
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
