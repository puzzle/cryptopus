# encoding: utf-8

#  Copyright (c) 2008-2017, Puzzle ITC GmbH. This file is part of
#  Cryptopus and licensed under the Affero General Public License version 3 or later.
#  See the COPYING file at the top-level directory or at
#  https://github.com/puzzle/cryptopus.

class User::Human
  module Authentication

    def authenticate(cleartext_password)
      return false if locked?
      return authenticate_ldap(cleartext_password) if ldap?

      authenticate_db(cleartext_password)
    end

    private

    def authenticate_ldap(cleartext_password)
      unless Setting.value('ldap', 'enable') == true
        raise 'cannot authenticate against ldap since ldap auth is disabled'
      end
      ldap_connection.login(username, cleartext_password)
    end
  end
end
