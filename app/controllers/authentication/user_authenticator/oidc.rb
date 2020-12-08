# frozen_string_literal: true

class Authentication::UserAuthenticator::Oidc < Authentication::UserAuthenticator

  def authenticate!
    return false if access_token.nil?

    preconditions? && oidc_signed_in?
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
    oidc_path
  end

  def user_logged_in?(session)
    session[:user_id].present? && user_authenticated?(session)
  end

  def oidc_login
    oidc_client.oidc_login_url(after_oidc_login_url)
  end

  def token(params)
    Keycloak::Client.get_token_by_code(params[:code], keycloak_login_url)
  end

  def logged_out_path
    oidc_inactive_path
  end

  def recrypt_path
    recrypt_oidc_path
  end

  def oidc_signed_in?
    return false if access_token.nil?

    oidc_client.user_signed_in?(access_token)
  end

  private

  def access_token
    @cookies['oidc_token'].try(:[], 'access_token')
  end

  def user_authenticated?(session)
    return true if session[:username] == 'root'

    oidc_signed_in?
  end

  def find_or_create_user
    user = User.find_by(username: username.strip)
    return create_user if user.nil? && oidc_signed_in?

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

  def keycloak_params
    { provider_uid: Keycloak::Client.get_attribute('sub', access_token),
      givenname: Keycloak::Client.get_attribute('given_name', access_token),
      surname: Keycloak::Client.get_attribute('family_name', access_token) }
  end

  def username
    @username ||= oidc_client.get_attribute('preferred_username', access_token)
  end

  def create_user
    provider_uid = Keycloak::Client.get_attribute('sub', access_token)
    psb = keycloak_client.find_or_create_pk_secret_base(access_token)
    User::Human.create(
      username: username,
      givenname: Keycloak::Client.get_attribute('given_name', access_token),
      surname: Keycloak::Client.get_attribute('family_name', access_token),
      provider_uid: provider_uid,
      auth: 'keycloak'
    ) { |u| u.create_keypair(keycloak_client.user_pk_secret(psb, access_token)) }
  end

  def params_present?
    Keycloak::Client.get_attribute('preferred_username', access_token).present?
  rescue JWT::DecodeError
    false
  end

  def oidc_client
    @oidc_client ||= OicdClient.new
  end
end
