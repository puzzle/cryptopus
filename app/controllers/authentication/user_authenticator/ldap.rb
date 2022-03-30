# frozen_string_literal: true

class Authentication::UserAuthenticator::Ldap < Authentication::UserAuthenticator

  def authenticate!
    raise 'ldap auth not enabled' unless AuthConfig.ldap_enabled?

    return false unless preconditions?
    return false if brute_force_detector.locked?

    authenticated = ldap_connection.authenticate!(username, password)
    brute_force_detector.update(authenticated)
    authenticated
  end

  def authenticate_by_headers!
    return false unless api_preconditions?

    case user
    when User::Human
      return authenticate!
    when User::Api
      return db_authenticator.authenticate_by_headers!
    end

    false
  end

  def updatable_user_attrs
    ldap_attrs
  end

  def recrypt_path
    recrypt_ldap_path
  end

  private

  def api_preconditions?
    params_present? &&
      valid_username? &&
      user.present?
  end

  def find_or_create_user
    return unless params_present? && valid_username?

    user = User.find_by(username: username.strip)
    return create_user if user.nil? && ldap_connection.authenticate!(username, password)

    user
  end

  def ldap_attrs
    { givenname: ldap_connection.ldap_info(user.provider_uid, 'givenname'),
      surname: ldap_connection.ldap_info(user.provider_uid, 'sn') }
  end

  def create_user
    provider_uid = ldap_connection.uidnumber_by_username(username)
    User::Human.create(
      username: username,
      givenname: ldap_connection.ldap_info(provider_uid, 'givenname'),
      surname: ldap_connection.ldap_info(provider_uid, 'sn'),
      provider_uid: provider_uid,
      auth: 'ldap'
    ) { |u| u.create_keypair(password) }
  end

  def ldap_connection
    @ldap_connection ||= LdapConnection.new
  end
end
