class Authenticator

  class << self
    def authenticate(user, password, opts = {})
      authenticator(user, password, opts).auth!
    end
    
    def temporarly_locked?(user)
      authenticator(user).user_temporarly_locked?
    end

    private
    def authenticator(user, password = nil, opts = {})
      if user.ldap?
        return Authenticators::Ldap.new(user, password, opts)
      end
      Authenticators::Db.new(user, password, opts)
    end
  end

end
