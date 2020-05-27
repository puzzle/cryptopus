# frozen_string_literal: true

class Authentication::UserAuthenticator::Ldap < Authentication::UserAuthenticator::External

  def authenticate!
    return false unless preconditions?

    authenticated = ldap_connection.authenticate!(username, password)

    add_error('flashes.session.wrong_password') unless authenticated
    authenticated
  end

  def find_or_create_user
    return nil unless params_present? && valid_username? && username == 'root' || ldap_connection.authenticate!(username, password)

    user = User.find_by(username: username.strip)
    return create_user if user.nil?

    user
  end

  def update_user_info(remote_ip)
    user.last_login_from = remote_ip
    user.last_login_at = Time.zone.now
    update_ldap_info unless user.root?
    user.save
  end


  private

  def create_user
    super(
      {
        givenname: ldap_connection.ldap_info(user.provider_uid, 'givenname'),
        surname: ldap_connection.ldap_info(user.provider_uid, 'sn'),
        provider_uid: ldap_connection.uidnumber_by_username(username)
      },
      password
    )
  end

  def update_ldap_info
    user.givenname = ldap_connection.ldap_info(user.provider_uid, 'givenname')
    user.surname = ldap_connection.ldap_info(user.provider_uid, 'sn')
  end

  def ldap_connection
    @ldap_connection ||= LdapConnection.new
  end
end
