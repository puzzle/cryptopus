# frozen_string_literal: true

class Authentication::AuthProvider::Ldap < Authentication::AuthProvider

  def authenticate!
    return false unless preconditions?

    authenticated = ldap_connection.authenticate!(username, password)

    add_error('flashes.session.wrong_password') unless authenticated
    authenticated
  end

  def find_or_create_user
    user = User.find_by(username: username.strip)
    return create_user(username, password) if user.nil?

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
    user = new
    user.username = username
    user.auth = 'ldap'
    user.provider_uid = ldap_connection.uidnumber_by_username(username)
    user.create_keypair password
    user
  end

  def ldap_connection
    @ldap_connection ||= LdapConnection.new
  end
end
# class User::Human
#   module Ldap
#
#     def self.included(base)
#       base.extend ClassMethods
#     end
#
#     module ClassMethods
#
#       def find_or_import_from_ldap(username, password)
#         user = find_by(username: username)
#
#         return user if user
#
#         if ldap_enabled?
#           return unless authenticate_ldap(username, password)
#
#           create_from_ldap(username, password)
#         end
#       end
#
#       def assert_ldap_enabled
#         unless ldap_enabled?
#           raise 'cannot perform ldap operation since ldap is disabled'
#         end
#       end
#
#       def ldap_enabled?
#         AuthConfig.ldap_enabled?
#       end
#
#       private
#
#       def ldap_connection
#         assert_ldap_enabled
#         LdapConnection.new
#       end
#
#       def create_from_ldap(username, password)
#         user = new
#         user.username = username
#         user.auth = 'ldap'
#         user.provider_uid = ldap_connection.uidnumber_by_username(username)
#         user.create_keypair password
#         user.update_info
#         user
#       rescue StandardError
#         raise Exceptions::UserCreationFailed
#       end
#     end
#
#     private
#
#     # Updates Information about the user from LDAP
#     def update_info_from_ldap
#       self.givenname = ldap_connection.ldap_info(provider_uid, 'givenname')
#       self.surname = ldap_connection.ldap_info(provider_uid, 'sn')
#     end
#
#     def ldap_connection
#       self.class.assert_ldap_enabled
#       LdapConnection.new
#     end
#
#   end
#
# end
