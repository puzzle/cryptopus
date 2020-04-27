# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class User::Human
  module KeycloakUser
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def create_from_keycloak(username)
        user = new
        user.username = username
        user.auth = 'keycloak'
        user.provider_uid = Keycloak::Client.get_attribute('sub')
        user.password = CryptUtils.create_pk_secret_base(user.provider_uid)
        user.create_keypair(CryptUtils.pk_secret(user.password))
        user.update_info
        user
      rescue StandardError
        raise Exceptions::UserCreationFailed
      end

      def keycloak_enabled?
        AuthConfig.keycloak_enabled?
      end
    end

    private

    # Updates Information about the user from Keycloak
    def update_info_from_keycloak
      self.givenname = Keycloak::Client.get_attribute('given_name')
      self.surname = Keycloak::Client.get_attribute('family_name')
    end
  end
end
