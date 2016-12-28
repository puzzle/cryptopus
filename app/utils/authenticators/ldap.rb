module Authenticators
  class Ldap < Base

    private
    def authenticated?
      authenticate_ldap
    end

    def authenticate_ldap
      LdapTools.ldap_login(@user.username, @password)
    end

  end
end
