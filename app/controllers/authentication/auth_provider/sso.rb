# frozen_string_literal: true

class Authentication::AuthProvider::Sso < Authentication::AuthProvider

  def initialize(username: nil)
    @authenticated = false
    @username = username
  end

  def update_user_info(remote_ip)
    user.update(
      last_login_from: remote_ip,
      last_login_at: Time.zone.now,
      givenname: Keycloak::Client.get_attribute('given_name'),
      surname: Keycloak::Client.get_attribute('family_name')
    )
  end

  def authenticate!
    return false unless preconditions?

    true
  end

  def find_or_create_user
    user = User.find_by(username: username.strip)
    return create_user if user.nil?

    user
  end

  private

  def create_user
    user = User::Human.new
    user.username = username
    user.givenname = Keycloak::Client.get_attribute('given_name')
    user.surname = Keycloak::Client.get_attribute('family_name')
    user.auth = 'keycloak'
    user.provider_uid = Keycloak::Client.get_attribute('sub')
    pk_secret_base = CryptUtils.create_pk_secret_base(user.provider_uid)
    user.create_keypair(CryptUtils.pk_secret(pk_secret_base))
    user.save
    user
  end

  def params_present?
    username.prsent?
  end
end

#
# class User::Human
#   module KeycloakUser
#     def self.included(base)
#       base.extend ClassMethods
#     end
#
#     module ClassMethods
#       def import_from_keycloak(username)
#         raise 'cannot perform this operation since keycloak is disabled' unless keycloak_enabled?
#         return unless Keycloak::Client.user_signed_in?
#
#         create_from_keycloak(username)
#       end
#
#       private
#
#       def keycloak_enabled?
#         AuthConfig.keycloak_enabled?
#       end
#

#       rescue StandardError
#         raise Exceptions::UserCreationFailed
#       end
#     end
#
#     private
#
#     # Updates Information about the user from Keycloak

#   end
# end
