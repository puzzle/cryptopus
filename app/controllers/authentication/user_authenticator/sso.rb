# frozen_string_literal: true

class Authentication::UserAuthenticator::Sso < Authentication::UserAuthenticator

  def authenticate!
    return false unless Keycloak::Client.user_signed_in?
    return false unless preconditions?
    return false if Keycloak::Client.get_attribute('pk_secret_base').nil?

    true
  end

  def update_user_info(remote_ip)
    params = { last_login_from: remote_ip }
    params.merge(keycloak_params) unless username == 'root'
    super(params)
  end

  def login_path
    session_sso_path
  end

  def user_logged_in?(session)
    session[:user_id].present? && session[:private_key].present? && Keycloak::Client.user_signed_in?
  end

  def logout
    Keycloak::Client.logout unless username == 'root'
  end

  def keycloak_login
    Keycloak::Client.url_login_redirect(session_sso_url, 'code')
  end

  def token(params)
    Keycloak::Client.get_token_by_code(params[:code], session_sso_url)
  end

  private

  def find_or_create_user
    return unless username == 'root' || Keycloak::Client.user_signed_in?

    user = User.find_by(username: username.strip)
    return create_user if user.nil?

    user
  end

  def session_sso_url
    protocol = Rails.application.config.force_ssl ? 'https://' : 'http://'
    protocol + (ENV['HOSTNAME'] || 'localhost:3000') + session_sso_path
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
