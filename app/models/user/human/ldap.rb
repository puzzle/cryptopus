# frozen_string_literal: true

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class User::Human
  module Ldap

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods

      def find_or_import_from_ldap(username, password)
        user = find_by(username: username)

        return user if user

        if ldap_enabled?
          return unless authenticate_ldap(username, password)

          create_from_ldap(username, password)
        end
      end

      def assert_ldap_enabled
        unless ldap_enabled?
          raise 'cannot perform ldap operation since ldap is disabled'
        end
      end

      def ldap_enabled?
        AuthConfig.ldap_enabled?
      end

      private

      def ldap_connection
        assert_ldap_enabled
        LdapConnection.new
      end

      def authenticate_ldap(username, cleartext_password)
        ldap_connection.authenticate!(username, cleartext_password)
      end

      def create_from_ldap(username, password)
        user = new
        user.username = username
        user.auth = 'ldap'
        user.provider_uid = ldap_connection.uidnumber_by_username(username)
        user.create_keypair password
        user.update_info
        user
      rescue StandardError
        raise Exceptions::UserCreationFailed
      end
    end

    private

    # Updates Information about the user from LDAP
    def update_info_from_ldap
      self.givenname = ldap_connection.ldap_info(provider_uid, 'givenname')
      self.surname = ldap_connection.ldap_info(provider_uid, 'sn')
    end

    def ldap_connection
      self.class.assert_ldap_enabled
      LdapConnection.new
    end

  end

end
