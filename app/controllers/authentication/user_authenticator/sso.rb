# frozen_string_literal: true

class Authentication::UserAuthenticator::Sso < Authentication::UserAuthenticator

  def initialize(username: nil, password: nil)
    @username = username
    @password = password
    @authenticated = false
  end

  def authenticate!
    return false unless Keycloak::Client.user_signed_in?
    return false unless preconditions?

    true
  end

  def find_or_create_user
    return unless username == 'root' || Keycloak::Client.user_signed_in?

    user = User.find_by(username: username.strip)
    return create_user if user.nil?

    user
  end

  def update_user_info(remote_ip)
    super(
      last_login_from: remote_ip,
      # provider_uid: Keycloak::Client.get_attribute('sub'),
      # givenname: Keycloak::Client.get_attribute('given_name'),
      # surname: Keycloak::Client.get_attribute('family_name')
    )
  end

  def login_path
    session_sso_path
  end

  def user_logged_in?(session)
    session[:user_id].present? && session[:private_key].present? && Keycloak::Client.user_signed_in?
  end


  private

  def username
    @username ||= Keycloak::Client.get_attribute('preferred_username')
  end

  def create_user
    pk_secret_base = Keycloak::Client.get_attribute('pk_secret_base') ||
                      KeycloakClient.create_pk_secret_base(Keycloak::Client.get_attribute('sub'))
    User::Human.create(
      username: username,
      givenname: Keycloak::Client.get_attribute('given_name'),
      surname: Keycloak::Client.get_attribute('family_name'),
      provider_uid: Keycloak::Client.get_attribute('sub'),
      auth: 'keycloak'
    ) { |u| u.create_keypair(keycloak_client.user_pk_secret) }
  end

  def params_present?
    username.present?
  end

  def keycloak_client
    @keycloak_client ||= KeycloakClient.new
  end
end
