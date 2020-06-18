# frozen_string_literal: true

class Authentication::UserAuthenticator::Ldap < Authentication::UserAuthenticator

  def authenticate!
    return false if root_user?
    return false unless preconditions?
    return false if brute_force_detector.locked?

    authenticated = ldap_connection.authenticate!(username, password)
    brute_force_detector.update(authenticated)
    authenticated
  end

  def authenticate_by_headers!
    return false if root_user?
    return false unless preconditions?
    return false if brute_force_detector.locked?


    if user.is_a?(User::Human)
      authenticated = ldap_connection.authenticate!(username, password)
    elsif user.is_a?(User::Api)
      authenticated = user.authenticate_db(password)
    end
    authenticated
  end

  def update_user_info(remote_ip)
    params = { last_login_from: remote_ip }
    params.merge(ldap_params) unless root_user?
    super(params)
  end

  def recrypt_path
    recrypt_ldap_path
  end

  private

  def find_or_create_user
    return unless params_present? && valid_username?

    user = User.find_by(username: username.strip)
    return create_user if user.nil? && ldap_connection.authenticate!(username, password)

    user
  end

  def ldap_params
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
