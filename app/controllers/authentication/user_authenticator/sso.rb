# frozen_string_literal: true

class Authentication::UserAuthenticator::Sso < Authentication::UserAuthenticator

  def authenticate!
    return false unless Keycloak::Client.user_signed_in?
    return false unless preconditions?
    return false if Keycloak::Client.get_attribute('pk_secret_base').nil?

    true
  end

  def authenticate_by_headers!
    return false unless header_preconditions?
    return false unless user.is_a?(User::Api)

    authenticated = user.authenticate_db(password)

    brute_force_detector.update(authenticated)
    authenticated
  end

  def update_user_info(remote_ip)
    params = { last_login_from: remote_ip }
    params.merge(keycloak_params) unless username == 'root'
    super(params)
  end

  def login_path
    sso_path
  end

  def user_logged_in?(session)
    session[:user_id].present? && session[:private_key].present? && Keycloak::Client.user_signed_in?
  end

  def keycloak_login
    Keycloak::Client.url_login_redirect(keycloak_login_url, 'code')
  end

  def token(params)
    Keycloak::Client.get_token_by_code(params[:code], keycloak_login_url)
  end

  private

  def find_or_create_user
    user = User.find_by(username: username.strip)
    return create_user if user.nil? && Keycloak::Client.user_signed_in?

    user
  end

  def header_preconditions?
    username.present? && password.present? && valid_username? && user.present? &&
          !brute_force_detector.locked? && username != 'root'
  end

  def keycloak_login_url
    protocol = Rails.application.config.force_ssl ? 'https://' : 'http://'
    protocol + (ENV['RAILS_HOST_NAME'] || 'localhost:3000') + sso_path
  end

  def keycloak_params
    { provider_uid: Keycloak::Client.get_attribute('sub'),
      givenname: Keycloak::Client.get_attribute('given_name'),
      surname: Keycloak::Client.get_attribute('family_name') }
  end

  def username
    @username ||= Keycloak::Client.get_attribute('preferred_username')
  end

  def create_user
    pk_secret_base = Keycloak::Client.get_attribute('pk_secret_base') ||
                      keycloak_client.create_pk_secret_base(Keycloak::Client.get_attribute('sub'))
    User::Human.create(
      username: username,
      givenname: Keycloak::Client.get_attribute('given_name'),
      surname: Keycloak::Client.get_attribute('family_name'),
      provider_uid: Keycloak::Client.get_attribute('sub'),
      auth: 'keycloak'
    ) { |u| u.create_keypair(keycloak_client.user_pk_secret(secret: pk_secret_base)) }
  end

  def params_present?
    Keycloak::Client.get_attribute('preferred_username').present?
  rescue StandardError
    false
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
