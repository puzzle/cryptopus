# frozen_string_literal: true

class Authentication::UserAuthenticator::Sso < Authentication::UserAuthenticator::External
  def initialize(username: nil, password: nil)
    @authenticated = false
    @username = username
    @password = password
    raise 'can\'t preform this action Keycloak is disabled' unless AuthConfig.keycloak_enabled?
  end

  def authenticate!
    return false unless preconditions?
    return false unless Keycloak::Client.user_signed_in?

    true
  end

  def find_or_create_user
    return unless username == 'root' || Keycloak::Client.user_signed_in?

    user = User.find_by(username: username.strip)
    return create_user if user.nil?

    user
  end

  def update_user_info(remote_ip)
    super({
      provider_uid: Keycloak::Client.get_attribute('sub'),
      givenname: Keycloak::Client.get_attribute('given_name'),
      surname: Keycloak::Client.get_attribute('family_name')
    })
  end

  private

  def create_user
    pk_secret_base = CryptUtils.pk_secret(Keycloak::Client.get_attribute('pk_secret_base') ||
                        CryptUtils.create_pk_secret_base(Keycloak::Client.get_attribute('sub')))
    super({
      givenname: Keycloak::Client.get_attribute('given_name'),
      surname: Keycloak::Client.get_attribute('family_name'),
      provider_uid: Keycloak::Client.get_attribute('sub')
    },
    pk_secret_base
    )
  end

  def params_present?
    username.present?
  end
end
