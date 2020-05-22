# frozen_string_literal: true

class Authentication::AuthProvider::Ldap < Authentication::AuthProvider

  def initialize(username: nil, password: nil)
    @authenticated = false
    @username = username
    @password = password
    raise 'can\'t preform this action Ldap is disabled' unless AuthConfig.ldap_enabled?
  end

  def authenticate!(new_password = nil)
    return false unless preconditions?

    password_to_check = new_password || password
    authenticated = ldap_connection.authenticate!(username, password_to_check)

    add_error('flashes.session.wrong_password') unless authenticated
    authenticated
  end

  def find_or_create_user
    return nil unless params_present? && valid_username? && ldap_connection.authenticate!(username, password)

    user = User.find_by(username: username.strip)
    return create_user if user.nil?

    user
  end

  def update_user_info(remote_ip)
    user.update(
      last_login_from: remote_ip,
      last_login_at: Time.zone.now,
      givenname: ldap_connection.ldap_info(user.provider_uid, 'givenname'),
      surname: ldap_connection.ldap_info(user.provider_uid, 'sn')
    )
  end

  private

  def create_user
    user = User.new
    user.username = username
    user.auth = 'ldap'
    user.provider_uid = ldap_connection.uidnumber_by_username(username)
    user.givenname = ldap_connection.ldap_info(user.provider_uid, 'givenname')
    user.surname = ldap_connection.ldap_info(user.provider_uid, 'sn')
    user.create_keypair password
    user.save
  end

  def ldap_connection
    @ldap_connection ||= LdapConnection.new
  end
end
