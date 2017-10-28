# encoding: utf-8

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

        if Setting.value(:ldap, :enable)
          return unless authenticate_ldap(username, password)
          create_from_ldap(username, password)
        end
      end

      def assert_ldap_enabled
        unless Setting.value('ldap', 'enable') == true
          raise 'cannot perform ldap operation since ldap is disabled'
        end
      end

      private

      def ldap_connection
        assert_ldap_enabled
        LdapConnection.new
      end

      def authenticate_ldap(username, cleartext_password)
        ldap_connection.login(username, cleartext_password)
      end

      def create_from_ldap(username, password)
        user = new
        user.username = username
        user.auth = 'ldap'
        user.ldap_uid = ldap_connection.uidnumber_by_username(username)
        user.create_keypair password
        user.update_info
        user
      rescue
        raise Exceptions::UserCreationFailed
      end
    end

    # instance methods
    def ldap?
      auth == 'ldap'
    end

    private

    # Updates Information about the user from LDAP
    def update_info_from_ldap
      self.givenname = ldap_connection.ldap_info(ldap_uid, 'givenname')
      self.surname = ldap_connection.ldap_info(ldap_uid, 'sn')
    end

    def ldap_connection
      self.class.assert_ldap_enabled
      LdapConnection.new
    end

  end

end
