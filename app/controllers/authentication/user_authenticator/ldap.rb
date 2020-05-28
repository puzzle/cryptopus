# frozen_string_literal: true

class Authentication::UserAuthenticator::Ldap < Authentication::UserAuthenticator

  def authenticate!
    return false if username == 'root'
    return false unless preconditions?
    return false if brute_force_detector.locked?

    authenticated = ldap_connection.authenticate!(username, password)

    authenticated
  end

  def find_or_create_user
    # TODO: policy to create user??
    return nil unless params_present? && valid_username? && username == 'root' || ldap_connection.authenticate!(username, password)

    user = User.find_by(username: username.strip)
    return create_user if user.nil?

    user
  end

  def update_user_info(remote_ip)
    super(
      last_login_from: remote_ip,
      givenname: ldap_connection.ldap_info(user.provider_uid, 'givenname'),
      surname: ldap_connection.ldap_info(user.provider_uid, 'sn')
    )
  end

  def user_logged_in?(session)
    session[:user_id].present? && session[:private_key].present? && user.recryptrequests.first.nil?
  end

  def login_path
    session_new_path
  end

  private

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
